// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * 可迭代的mapping
 * @title 
 * @author 
 * @notice 
 */
library IterableMapping {
    
    struct Map {
        address[] keys;
        mapping (address => uint256) values;
        mapping (address => uint256) indexOf;
        mapping (address => bool) inserted;
    }

    function get(Map storage map , address key) public view returns (uint256){
        return map.values[key];
    }

    function put(Map storage map, address key , uint256 val ) public {
        if( map.inserted[key]){
            map.values[key] = val;
        }else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function getKeyAtIndex(Map storage map, uint256 index) public view returns (address){
        return map.keys[index];
    }

    function remove(Map storage map , address key) public {
        if( !map.inserted[key]){
            return ;
        }
        delete map.inserted[key];
        delete map.values[key];

        // 将最后一个key放到要删除的key的地方
        uint index = map.indexOf[key];
        address lastKey = map.keys[map.keys.length-1];
        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }

    function size(Map storage map ) public view returns (uint256) {
        return map.keys.length;
    }
}


contract  TestIterableMap {
    // 将IterableMapping 库 用到 IterableMapping.Map类型
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private map;

    function getMapSize() public view returns(uint256){
        return map.size();
    }

    function testIterableMap() public {
        
        map.put(address(0),0);
        map.put(address(1),100);
        map.put(address(2),200);
        map.put(address(3),300);

        for (uint i = 0; i < map.size(); i++) {
            address key = map.getKeyAtIndex(i);
            assert(map.get(key) == i * 100);
        }

        map.remove(address(1));

        assert(map.size() == 3);
        assert(map.getKeyAtIndex(0) == address(0));
        assert(map.getKeyAtIndex(1) == address(3));
        assert(map.getKeyAtIndex(2) ==  address(2));
    }
}