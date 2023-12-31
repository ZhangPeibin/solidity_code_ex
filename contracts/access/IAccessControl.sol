// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

interface  IAccessControl {
    
    /**
     * @dev the 'account' is missing a role
     */
    error AccessControlUnauthorizedAccount(address account,bytes32 neededRole);


    error AccessControlBadConfimation();   


    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole,
    bytes32 indexed newAdminRole);


    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);



    function hasRole(bytes32 role, address account) external view returns (bool) ;

    function getRoleAdmin(bytes32 role) external view returns(bytes32);

    function grantRole(bytes32 role,address account ) external;

    function revokeRole(bytes32 role,address accont) external;

    function renounceRole(bytes32 role, address callerConfirmation) external;

}   