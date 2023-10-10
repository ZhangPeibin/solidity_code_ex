// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

library  Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    error StringsInsufficientHexLength(uint256 value,uint256 length);

    function toString(uint256 value) internal pure returns(string memory) {
        //不需要溢出检查，那么需要自己进行溢出检查
        unchecked {
            uint256 length = 
        }
    }
}