// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * 简单支付通道。
 * A -> B 发送
 * A 到时可以 关闭
 * B 可以在时间内领取money
 * @title
 * @author
 * @notice
 */
contract SimplePaymentChannel {
    address payable public sender; // who send money

    address payable public recipient; // how receive money

    uint256 public expiration; // Timeout

    constructor(address payable _recipient, uint256 duration) payable {
        sender = payable(msg.sender);
        recipient = payable(_recipient);
        expiration = block.timestamp + duration;
    }

    /**
     * B来关闭支付通道
     * @param amount  金额
     * @param signature  签名消息
     */
    function close(uint256 amount, bytes memory signature) external{
        require(msg.sender == recipient);
        require(isValidSignature(amount,signature));
        (bool success,) = recipient.call{value:amount}("");
        if(!success){
            revert("cal fail");
        }

        (success,) = payable(sender).call{value: address(this).balance}("");
        if (!success) {
            revert("call{value} failed");
        }
    }
    
    function extend(uint256 newExpiration) external{
        require(msg.sender == sender);
        require(newExpiration > expiration);
        expiration = newExpiration;
    }


    function claimTimeout() external{
        require(block.timestamp >= expiration);//如果过期了，那么就能销毁
        (bool success,) = payable(sender).call{value: address(this).balance}("");
        if (!success) {
            revert("call{value} failed");
        }
    }


    function isValidSignature(uint256 amount, bytes memory signature) public view returns(bool){
        bytes32 message = ethSignedMessage(address(this),amount);
        return recoverSigner(message,signature) == sender;
    }

    function splitSignature(
        bytes memory sig
    ) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    function recoverSigner(
        bytes32 message,
        bytes memory sign
    ) public pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sign);
        return ecrecover(message, v, r, s);
    }

    function messageHash(
        address _contractAddress,
        uint256 amount
    ) public pure returns (bytes32) {
        bytes32 message = keccak256(abi.encodePacked(_contractAddress, amount));
        return message;
    }

    function ethSignedMessage(
        address _contractAddress,
        uint256 amount
    ) public pure returns (bytes32) {
        bytes32 message = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(_contractAddress, amount))
            )
        );
        return message;
    }
}
