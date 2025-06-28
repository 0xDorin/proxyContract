// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from '../proxy/Initializable.sol';
import {Ownable} from '../utils/Ownable.sol';

contract MockupNad is Initializable, Ownable {
    uint256 public nadValue;

    constructor(address owner) {
        _transferOwnership(owner);
    }

    function initialize(uint256 _chainId) initializable public {
        _transferOwnership(_msgSender());
    }
    
    event NadFunctionCalled(uint256 input, uint256 result);
    
    function nadFunction(uint256 _input) public returns (uint256) {
        nadValue = _input + 100;
        emit NadFunctionCalled(_input, nadValue);
        return nadValue;
    }

    function nadFunctionOwner(uint256 _input) public onlyOwner returns (uint256) {
        nadValue = _input + 300;
        emit NadFunctionCalled(_input, nadValue);
        return nadValue;
    }
} 