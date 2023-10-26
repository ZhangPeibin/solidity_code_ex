// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//@notice modern and gas efficient ERC20 + EIP-2612 implementation.abi

abstract contract ERC20 {
    /** event */

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    /** META STORAGE */

    string public name;
    string public symbol;
    uint8 public immutable decimals;

    /** ERC20 STORAGE */
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /** EIP-2612 STORAGE */

    uint256 internal immutable INITTAL_CHAIN_ID;

    bytes32 internal immutable INITTAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITTAL_CHAIN_ID = block.chainid;
        INITTAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////// 
                    ERC20 LOGIC
    /*/ /////////////////////////////////////////////////////// */

    function approve(
        address sender,
        uint256 amount
    ) public virtual returns (bool) {
        // msg.sender 允许sender 使用amount  token
        allowance[msg.sender][sender] = amount;
        emit Approval(msg.sender, sender, amount);
        return true;
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        // A approve B => allowance[a][B] = amount
        // from = a , msg.sender = b
        uint256 allowed = allowance[from][msg.sender];
        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // 不用进行overflow 检查，因为所有的balance都不可能比uint256 大
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);
        return true;
    }

    /*//////////////////////////////////////////////////////// 
                    EIP-2612 LOGIC
                    https://eips.ethereum.org/EIPS/eip-2612
    /*/ /////////////////////////////////////////////////////// */

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
        unchecked {
            address signer = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(
                signer != address(0) && signer == owner,
                "INVALID_SIGNER"
            );
            allowance[signer][spender] = value;
            emit Approval(owner,spender,value);
        }
    }

    /**
     * 有可能block.chainid 不跟我们部署的一样?
     */
    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return
            block.chainid == INITTAL_CHAIN_ID
                ? INITTAL_DOMAIN_SEPARATOR
                : computeDomainSeparator();
    }

    /**
     * @notice https://eips.ethereum.org/EIPS/eip-2612
     */
    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name)),
                    keccak256(bytes("1")),
                    block.chainid,
                    address(this)
                )
            );
    }


    /*//////////////////////////////////////////////////////// 
                    INTERNAL MINT/BURN LOGIC
    /*/ /////////////////////////////////////////////////////// */

    function _mint(address to , uint256 amount) internal virtual{
        totalSupply += amount;
        unchecked{
            balanceOf[to] += amount;
        }
        emit Transfer(address(0),to,amount);
    }

    function _burn(address from , uint256 amount) internal virtual{
        balanceOf[from] -= amount;
        unchecked{
            totalSupply -= amount;
        }
        emit Transfer(from ,address(0),amount);
    }
}
