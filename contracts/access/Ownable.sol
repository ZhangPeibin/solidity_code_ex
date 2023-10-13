// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);

    /**
     * the owner 不是一个正常的owner
     */
    error OwnableInvalidowner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newowner
    );

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidowner(initialOwner);
        }
        _owner = initialOwner;
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() internal view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidowner(newOwner);
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address _oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(_oldOwner,_owner);
    }
}
