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
        
        // Deploy contracts with required constructor parameters
        proxy = new Proxy(admin);
        mockupNad = new MockupNad(admin);
        mockupAnother = new MockupAnother(admin);
        
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

} 