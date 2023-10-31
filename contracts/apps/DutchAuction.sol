// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

interface IERC721 {
    function transferFrom(address _from, address _to, uint256 _nftId) external;
}

/**
 * @title 荷兰拍卖
 * @author 
 * @notice 
 * 1: 卖方部署合约，并设置nft价格
 * 2: 拍卖持续7天
 * 3: NFT的价格随着时间的推移而下降
 * 4: 参与者可以通过存入高于智能合约计算的当前价格的ETH来购买
 * 5: 当买家购买nft的时候，拍卖结束
 */
contract DutchAuction{
    uint private constant DURATION = 7 days;

    address seller;
    IERC721 public immutable nft;  // 拍卖的nft
    uint256 public immutable nftId;
    uint256 public immutable startingPrice; //起始的价格
    uint256 public immutable startAt;  // 什么时候开始
    uint256 public immutable expiresAt; // 什么时候过期
    uint256 public immutable discountRate; // 价格变少的频率

    constructor(address _nft, uint256 _startingPrice, uint256 _startAt, uint256 _discountRate,uint256 _nftId){
        seller = msg.sender;
        nft = IERC721(_nft);
        nftId = _nftId;
        startingPrice = _startingPrice;
        startAt = _startAt;
        expiresAt = _startAt + DURATION;
        discountRate = _discountRate;
    }


    function getPrice() public view returns(uint256){
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable{
        require(block.timestamp < expiresAt,"auction expired");
        uint256 price = getPrice();
        require(msg.value >= price, "ETH < price");
        nft.transferFrom(seller,msg.sender,nftId);
        uint refund = msg.value - price;
        if(refund >0 ){
            payable(msg.sender).transfer(refund);
        }

        (bool success,) = payable(seller).call{value:address(this).balance}("");
        if(!success){
            revert();
        }
    }
}

