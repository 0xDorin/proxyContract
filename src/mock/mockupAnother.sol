// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from '../proxy/Initializable.sol';
import {Ownable} from '../utils/Ownable.sol';

contract MockupAnother is Initializable, Ownable {
    uint256 public anotherValue;
    
    constructor(address owner) {
        _transferOwnership(owner);
    }

    function initialize(uint256 _chainId) initializable public {
        _transferOwnership(_msgSender());
    }
    
    event AnotherFunctionCalled(uint256 input, uint256 result);
    
    function anotherFunction(uint256 _input) public returns (uint256) {
        anotherValue = _input * 5;
        emit AnotherFunctionCalled(_input, anotherValue);
        return anotherValue;
    }

    function anotherFunctionOwner(uint256 _input) public onlyOwner returns (uint256) {
        anotherValue = _input * 5;
        emit AnotherFunctionCalled(_input, anotherValue);
        return anotherValue;
    }
} 