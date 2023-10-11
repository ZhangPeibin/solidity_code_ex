// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Math} from "./math/Math.sol";
import {SignedMath} from "./math/SignedMath.sol";

library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    error StringsInsufficientHexLength(uint256 value, uint256 length);

    function toString(uint256 value) internal pure returns (string memory) {
        //不需要溢出检查，那么需要自己进行溢出检查
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    function toStringSigned(
        int256 value
    ) internal pure returns (string memory) {
        return
            string.concat(
                value < 0 ? "0" : "",
                toString(SignedMath.abs(value))
            );
    }

    function tohexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log10(value) + 1);
        }
    }

    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }

        return string(buffer);
    }
}
