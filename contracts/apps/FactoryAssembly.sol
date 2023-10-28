// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract FactoryAssembly {

    event ContractDepoly(address indexed a, bytes32 indexed salt);

    function deployByNew(
        address _owner,
        uint256 _foo,
        bytes32 _salt
    ) public payable {
        TestContract t = new TestContract{salt: _salt}(_owner, _foo);
        emit ContractDepoly(address(t),_salt);
    }


    function calculateBytecode(address _owner, uint256 _foo) public pure returns(bytes memory){
        bytes memory bytecode = type(TestContract).creationCode;
        return abi.encodePacked(bytecode,abi.encode(_owner,_foo));
    }

    function calculateAddr(bytes memory bytecode, bytes32  _salt) public view returns(address){
        bytes32 hashValue = keccak256(
            abi.encodePacked(bytes1(0xff),address(this),_salt,keccak256(bytecode))
        );
        return address(uint160(uint256(hashValue)));
    }


    /**
     * bytes的编码
     * 0x
     * 000000000.......000020 : bytes数据的起始位置，32个字节
     * 000000000.......000010 : bytes的长度   也是32个字节
     * bytecode ........000000 : bytes的具体的值， 也是32个字节
     * @param bytecode  字节码
     * @param _salt  盐
     */
    function deployByAssembly(bytes memory bytecode, bytes32 _salt) public payable{
        address addr;
        assembly {
            addr := create2(
                callvalue(), // 你要给这个合约的钱
                add(bytecode,0x20), // bytecode指针指向bytecode内存的第一个，然后加0x20则指向第32，因为
                // bytes 的 数据从第33位开始。前面的32是告诉数据从第多少开始
                mload(bytecode), 
                //  因为上面add导致bytecode 指针指向了33个字节，那么mload加载了32个字节也就是bytecode的size
                _salt
            )
            // 如果合约的codesize = 0 就是不合理的，
            if iszero(extcodesize(addr)){
                revert(0,0)
            }
        }
        
        emit ContractDepoly(addr,_salt);
    }
}

contract TestContract {
    address public owner;
    uint256 public foo;

    constructor(address _owner, uint256 _foo) payable {
        owner = _owner;
        foo = _foo;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
