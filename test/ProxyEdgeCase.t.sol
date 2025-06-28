// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/proxy/Proxy.sol";
import "../src/mock/mockupNad.sol";
import "../src/mock/mockupAnother.sol";

contract ProxyEdgeCaseTest is Test {
    Proxy public proxy;
    MockupNad public mockupNad;
    MockupAnother public mockupAnother;
    
    address admin = address(0x10);
    address user = address(0x20);
    
    function setUp() public {
        vm.startPrank(admin);
        
        // Deploy contracts
        proxy = new Proxy();
        mockupNad = new MockupNad();
        mockupAnother = new MockupAnother();
        
        vm.stopPrank();
    }

    // 핵심 테스트: MockupNad impl에서 MockupAnother 함수 호출 시도
    function testWrongFunctionCall() public {
        // MockupNad를 구현체로 설정
        vm.prank(admin);
        proxy.setImplementation(address(mockupNad));
        
        console.log("=== Wrong Function Call Test ===");
        console.log("Set MockupNad as implementation");
        console.log("Now trying to call MockupAnother function directly...");
        
        // 프록시를 MockupAnother로 감싸서 직접 함수 호출
        MockupAnother wrappedProxy = MockupAnother(address(proxy));
        
        // 실제 revert가 발생하는지 확인
        vm.expectRevert();
        wrappedProxy.anotherFunction(100);
        
        console.log("Revert occurred as expected!");
    }

    // 반대 케이스도 테스트
    function testWrongFunctionCallReverse() public {
        // MockupAnother를 구현체로 설정
        vm.prank(admin);
        proxy.setImplementation(address(mockupAnother));
        
        console.log("=== Reverse Wrong Function Call Test ===");
        console.log("Set MockupAnother as implementation");
        console.log("Now trying to call MockupNad function directly...");
        
        // 프록시를 MockupNad로 감싸서 직접 함수 호출
        MockupNad wrappedProxy = MockupNad(address(proxy));
        
        // 실제 revert가 발생하는지 확인
        vm.expectRevert();
        wrappedProxy.nadFunction(50);
        
        console.log("Revert occurred as expected!");
    }

    // 구현체가 없는 상태에서 여러 함수 호출 테스트
    function testMultipleCallsWithoutImplementation() public {
        // 구현체를 설정하지 않은 상태
        
        console.log("=== Multiple Calls Without Implementation Test ===");
        
        bytes memory callData1 = abi.encodeWithSignature("nadFunction(uint256)", 123);
        bytes memory callData2 = abi.encodeWithSignature("anotherFunction(uint256)", 456);
        bytes memory callData3 = abi.encodeWithSignature("nonExistentFunction()");
        
        (bool success1, ) = address(proxy).call(callData1);
        (bool success2, ) = address(proxy).call(callData2);  
        (bool success3, ) = address(proxy).call(callData3);
        
        console.log("NadFunction call success:", success1);
        console.log("AnotherFunction call success:", success2);
        console.log("NonExistent call success:", success3);
        
        // 모두 실패해야 함
        assertFalse(success1);
        assertFalse(success2);
        assertFalse(success3);
    }
} 