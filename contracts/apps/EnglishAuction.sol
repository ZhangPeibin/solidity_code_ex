// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 *
 *
 * @title 英国拍卖
 * @author peibin
 * @notice
 * 1. NFT 卖方部署此合约
 * 2. 拍卖会持续7天
 * 3. 参与者可以通过存入高于当前最高出价者的ETH来出价
 * 4. 如果不是当前的最高出价，所有投标人都可以都可以撤回其出价
 *
 */
contract EnglishAuction {
    event Start(); // 开始拍卖
    event Bid(address indexed sender, uint256 amount); //出价
    event Withdraw(address indexed bidder, uint256 amount); //出价的可以提走钱
    event End(address winner, uint256 amount); //结束拍卖

    IERC721 public nft; // 拍卖的nft
    uint256 public nftId; // nft的id

    address payable public seller; // 卖nft的人
    uint256 public endAt; //结束时间
    bool public started; //是否开始
    bool public ended; //是否结束

    address public highestBidder; // 最高价的地址
    uint256 public highestBid; // 最高价
    mapping(address => uint) public bids; // 出价记录

    constructor(address _nft, uint _nftId, uint256 _startingBid) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    /**
     * 开始拍卖
     */
    function start() external {
        require(!started, "started"); //拍卖已经开始
        require(msg.sender == seller, "not seller"); //必须卖的人开始

        nft.transferFrom(msg.sender, address(this), nftId); // 将卖方的nft转到合约来
        started = true;
        endAt = block.timestamp + 7 days; //拍卖为7天
        emit Start();
    }

    function bid() external payable {
        require(started, "bid not start");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest");

        // 每次有下一个bid的时候则更新上一个最高价的数据
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 bal = bids[msg.sender];
        //先生效
        bids[msg.sender] = 0;
        //在交互
        (bool success, ) = payable(msg.sender).call{value: bal}("");

        require(success, "withdraw failed");

        emit Withdraw(msg.sender, bal);
    }

    function end() external {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");
        ended = true;

        if (highestBidder != address(0)) {
            // 没有拍卖者
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
        }
    }
}

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(address from, address to, uint256 tokenId) external;
}
