// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/proxy/Proxy.sol";
import "../src/mock/mockupNad.sol";
import "../src/mock/mockupAnother.sol";

contract DeployScript is Script {
    // Create2 salt for deterministic addresses
    bytes32 constant PROXY_SALT = keccak256("PROXY_V1");
    bytes32 constant MOCKUP_NAD_SALT = keccak256("MOCKUP_NAD_V1");
    bytes32 constant MOCKUP_ANOTHER_SALT = keccak256("MOCKUP_ANOTHER_V1");
    
    // Deployed contract addresses (will be calculated)
    address payable public proxyAddress;
    address public mockupNadAddress;
    address public mockupAnotherAddress;
    address public deployer;
    
    function run() external {
        vm.startBroadcast();
        deployer = msg.sender;
        console.log("=== Deploying contracts ===");
        console.log("Deployer:", msg.sender);
        
        // Deploy contracts using Create2
        deployMockContracts();
        
        deployProxy();
        setupProxy();
        testDeployments();
        
        vm.stopBroadcast();
        
        printAddresses();
    }
    
    function deployMockContracts() internal {
        console.log("\n--- Deploying Mock Contracts ---");
        
        // Calculate expected addresses using vm.computeCreate2Address with correct deployer
        bytes32 initHash = keccak256(
            abi.encodePacked(
                type(MockupNad).creationCode,
                abi.encode(deployer)
            )
        );

        mockupNadAddress = vm.computeCreate2Address(
            MOCKUP_NAD_SALT,
            initHash
        );
        
        console.log("Expected MockupNad address:", mockupNadAddress);

        
        // Deploy MockupNad
        MockupNad mockupNad = new MockupNad{salt: MOCKUP_NAD_SALT}(msg.sender);
        require(address(mockupNad) == mockupNadAddress, "MockupNad address mismatch");
        console.log("MockupNad deployed at:", address(mockupNad));

        bytes32 initHash2 = keccak256(
            abi.encodePacked(
                type(MockupAnother).creationCode,
                abi.encode(deployer)
            )
        );

        mockupAnotherAddress = vm.computeCreate2Address(
            MOCKUP_ANOTHER_SALT,
            initHash2
        );
        
        console.log("Expected MockupAnother address:", mockupAnotherAddress);
        
        // Deploy MockupAnother
        MockupAnother mockupAnother = new MockupAnother{salt: MOCKUP_ANOTHER_SALT}(msg.sender);
        require(address(mockupAnother) == mockupAnotherAddress, "MockupAnother address mismatch");
        console.log("MockupAnother deployed at:", address(mockupAnother));
    }
    
    function deployProxy() internal {
        console.log("\n--- Deploying Proxy Contract ---");

        bytes32 initHash3 = keccak256(
            abi.encodePacked(
                type(Proxy).creationCode,
                abi.encode(deployer)
            )
        );
        
        // Calculate expected proxy address
        proxyAddress = payable(vm.computeCreate2Address(
            PROXY_SALT,
            initHash3
        ));
        
        console.log("Expected Proxy address:", proxyAddress);
        
        // Deploy Proxy
        Proxy proxy = new Proxy{salt: PROXY_SALT}(msg.sender);
        console.log("  Proxy deployed at:", address(proxy));
        console.log("  Proxy admin:", proxy.getAdmin());
        console.log("  msg.sender (should be EOA):", msg.sender);
        
        require(address(proxy) == proxyAddress, "Proxy address mismatch");
        
        if (proxy.getAdmin() != msg.sender) {
            console.log("UNEXPECTED: Admin is not msg.sender!");
            console.log("   This suggests vm.startBroadcast() is not working as expected");
        } else {
            console.log("EXPECTED: Admin is msg.sender (broadcast working correctly)");
        }
    }
    
    function setupProxy() internal {
        console.log("\n--- Setting up Proxy ---");
        
        Proxy proxy = Proxy(proxyAddress);
        bool success = proxy.setImplementation(mockupNadAddress);
        require(success, "Failed to set implementation");
        console.log("Implementation set to:", proxy.getImplementation());
    }
    
    function testDeployments() internal {
        console.log("\n--- Testing Deployments ---");
        
        // Type cast proxy to MockupNad and call functions directly
        MockupNad mockupNadProxy = MockupNad(proxyAddress);
        
        // Test nadFunction
        uint256 result = mockupNadProxy.nadFunction(42);
        console.log("Test call successful, result:", result);
        
        // Check storage was updated
        uint256 storedValue = mockupNadProxy.nadValue();
        console.log("Stored value:", storedValue);
    }
    
    function printAddresses() internal view {
        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("Proxy:", proxyAddress);
        console.log("MockupNad:", mockupNadAddress);
        console.log("MockupAnother:", mockupAnotherAddress);
        console.log("========================");
    }
} 