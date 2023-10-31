// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract HelloERC20 is ERC20 {
    constructor(uint256 initialSupply) ERC20("Hello", "hello") {
        _mint(msg.sender, initialSupply);
    }
    
    function mint() external{
        _mint(msg.sender,10000);
    }
}