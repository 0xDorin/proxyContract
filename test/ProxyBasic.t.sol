// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/proxy/Proxy.sol";
import "../src/mock/mockupNad.sol";
import "../src/mock/mockupAnother.sol";

contract ProxyBasicTest is Test {
    Proxy public proxy;
    MockupNad public mockupNad;
    MockupAnother public mockupAnother;
    
    address admin = address(0x1);
    address user = address(0x2);
    
    event Upgraded(address indexed _implementation);
    event NadFunctionCalled(uint256 input, uint256 result);
    
    function setUp() public {
        vm.startPrank(admin);
        
        // Deploy contracts with required constructor parameters
        proxy = new Proxy(admin);
        mockupNad = new MockupNad(admin);
        mockupAnother = new MockupAnother(admin);
        
        vm.stopPrank();
    }
    
    function testProxyDeployment() public {
        // Check that proxy was deployed correctly
        assertEq(proxy.getAdmin(), admin);
        assertEq(proxy.getImplementation(), address(0));
    }
    
    function testSetImplementation() public {
        vm.startPrank(admin);
        
        // Set mockupNad as implementation
        vm.expectEmit(true, false, false, false);
        emit Upgraded(address(mockupNad));
        
        bool success = proxy.setImplementation(address(mockupNad));
        assertTrue(success);
        assertEq(proxy.getImplementation(), address(mockupNad));
        
        vm.stopPrank();
    }
    
    function testDelegateCallSuccess() public {
        // First set implementation
        vm.prank(admin);
        proxy.setImplementation(address(mockupNad));
        
        // Prepare call data for nadFunction(123)
        bytes memory callData = abi.encodeWithSignature("nadFunction(uint256)", 123);
        
        // Expect the event from MockupNad
        vm.expectEmit(true, false, false, false);
        emit NadFunctionCalled(123, 223); // 123 + 100 = 223
        
        // Call through proxy
        (bool success, bytes memory returnData) = address(proxy).call(callData);
        assertTrue(success);
        
        // Check return value
        uint256 result = abi.decode(returnData, (uint256));
        assertEq(result, 223);
        
        // Check that storage was updated in proxy context
        bytes memory getValueCallData = abi.encodeWithSignature("nadValue()");
        (bool getSuccess, bytes memory getValue) = address(proxy).call(getValueCallData);
        assertTrue(getSuccess);
        uint256 storedValue = abi.decode(getValue, (uint256));
        assertEq(storedValue, 223);
    }
    
    function testDelegateCallWithDifferentImplementation() public {
        vm.startPrank(admin);
        
        // First set mockupNad as implementation
        proxy.setImplementation(address(mockupNad));
        vm.stopPrank();
        
        // Call nadFunction
        bytes memory callData1 = abi.encodeWithSignature("nadFunction(uint256)", 100);
        (bool success1, ) = address(proxy).call(callData1);
        assertTrue(success1);
        
        // Change implementation to mockupAnother
        vm.prank(admin);
        proxy.setImplementation(address(mockupAnother));
        
        // Now call anotherFunction
        bytes memory callData2 = abi.encodeWithSignature("anotherFunction(uint256)", 10);
        (bool success2, bytes memory returnData2) = address(proxy).call(callData2);
        assertTrue(success2);
        
        uint256 result = abi.decode(returnData2, (uint256));
        assertEq(result, 50); // 10 * 5 = 50
    }
    
    function test_RevertWhen_NoImplementationSet() public {
        // Don't set any implementation - should fail
        bytes memory callData = abi.encodeWithSignature("nadFunction(uint256)", 123);
        
        // This should revert because no implementation is set (delegatecall to address(0))
        vm.expectRevert();
        address(proxy).call(callData);
    }
    
    function testOnlyAdminCanSetImplementation() public {
        // Try to set implementation as non-admin user
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("NotAdmin(address)", user));
        proxy.setImplementation(address(mockupNad));
        
        // Admin should be able to set implementation
        vm.prank(admin);
        bool success = proxy.setImplementation(address(mockupNad));
        assertTrue(success);
    }
    
    function testUpgradeAndCall() public {
        vm.startPrank(admin);
        
        // Prepare call data for initialization
        bytes memory initCallData = abi.encodeWithSignature("nadFunction(uint256)", 999);
        
        // Expect events
        vm.expectEmit(true, false, false, false);
        emit Upgraded(address(mockupNad));
        vm.expectEmit(true, false, false, false);
        emit NadFunctionCalled(999, 1099); // 999 + 100 = 1099
        
        // Upgrade and call in one transaction
        bool success = proxy.upgradeAndCall(address(mockupNad), initCallData);
        assertTrue(success);
        
        // Verify implementation was set and function was called
        assertEq(proxy.getImplementation(), address(mockupNad));
        
        // Check that the function was executed
        bytes memory getValueCallData = abi.encodeWithSignature("nadValue()");
        (bool getSuccess, bytes memory getValue) = address(proxy).call(getValueCallData);
        assertTrue(getSuccess);
        uint256 storedValue = abi.decode(getValue, (uint256));
        assertEq(storedValue, 1099);
        
        vm.stopPrank();
    }

    function testSetAdmin() public {
        address newAdmin = address(0x999);
        
        vm.prank(admin);
        bool success = proxy.setAdmin(newAdmin);
        
        assertTrue(success);
        assertEq(proxy.getAdmin(), newAdmin);
        
        // Old admin should not be able to set implementation anymore
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSignature("NotAdmin(address)", admin));
        proxy.setImplementation(address(mockupNad));
        
        // New admin should be able to set implementation
        vm.prank(newAdmin);
        success = proxy.setImplementation(address(mockupNad));
        assertTrue(success);
    }
} 