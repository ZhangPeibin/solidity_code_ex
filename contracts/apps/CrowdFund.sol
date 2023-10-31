// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);
}

contract CrowdFund {

    event Launch(uint256,address,uint256,uint32,uint32);
    event Cancel(uint256);
    event Pledge(uint256,address,uint256);
    event Unplege(uint256,address,uint256);
    event Claim(uint256);
    event Refund(uint256 , address, uint256);

    // 众筹活动
    struct Campaign {
        address creator;
        uint256 goal; // 目标
        uint256 pledged; // 众筹金额
        uint32 startAt; // 开始时间
        uint32 endAt; //结束时间
        bool claimed; //是否 领取
    }   

    IERC20 public immutable token;

    uint256 count ;
    mapping(uint256 => Campaign) campaigns;
    mapping (uint256 => mapping (address => uint256) ) pledgedAmount;


    constructor(address _token) {
        token = IERC20(_token);
    }

    /**
     * 发起一个众筹
     * @param _goal 众筹目标
     * @param _startAt 开始时间
     * @param _endAt  结束时间
     */
    function launch(uint256 _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");
        count ++;
        campaigns[count] = Campaign({
            creator : msg.sender,
            goal : _goal,
            pledged:0,
            startAt : _startAt,
            endAt : _endAt,
            claimed:false
        });
        emit Launch(count,msg.sender,_goal,_startAt,_endAt);
    }

    function cancel(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender,"not creator");
        require(block.timestamp < campaign.startAt,"started");
        
        delete campaigns[_id];
        emit Cancel(_id);
    }

    /**
     * 捐赠
     * @param _id 活动的id
     * @param _amount 捐赠的金额
     */
    function pledge(uint256 _id, uint256 _amount) external{
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt,"not started");
        require(block.timestamp <= campaign.endAt,"ended");
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender,address(this),_amount);
        emit Pledge(_id,msg.sender,_amount);
    }


    function unpledge(uint256 _id,uint256 _amount) external{
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt,"not started");
        require(block.timestamp <= campaign.endAt,"ended");
        campaign.pledged -=_amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender,_amount);
        emit Unplege(_id,msg.sender,_amount);
    }

    function claim(uint256 _id) external{
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender,"not creator");
        require(block.timestamp >= campaign.startAt,"not started");
        require(block.timestamp <= campaign.endAt,"ended");
        require(campaign.pledged >= campaign.goal,"pledged < goal");
        require(!campaign.claimed,"claimed");
        campaign.claimed = true;
        token.transfer(campaign.creator,campaign.pledged);
        emit Claim(_id);
    }   

    function refund(uint256 _id) external{
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt,"not ended");
        require(campaign.pledged < campaign.goal,"pledged >= goal");
        uint256 bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender,bal);
        emit Refund(_id,msg.sender,bal);
    }


}
