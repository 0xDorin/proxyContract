// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { AbstractProxy } from './AbstractProxy.sol';
import { ProxyStorage } from './ProxyStorage.sol';
import { TransferHelper } from '../utils/TransferHelper.sol';
import {console} from 'forge-std/console.sol';

contract Proxy is AbstractProxy {

    address constant internal nativeAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    event Upgraded(address indexed _implementation);
    event ChangedAdmin(address indexed _previousAdmin, address indexed _newAdmin);
    event Withdrawn(address indexed _tokenAddr, address indexed _recipient, uint256 _amount);

    error InvalidImplementation(address _implementation);
    error InvalidAdmin(address admin);
    error NotAdmin(address sender);

    constructor(address owner) {
        ProxyStorage.load().admin = owner;
        console.log("Proxy constructor", msg.sender);
    }

    modifier onlyAdmin() {
        address msgSender = msg.sender;

        if (msgSender != _admin()) {
            revert NotAdmin(msgSender);
        }
        
        _;
    }

    function upgradeAndCall(address _newImplementation, bytes calldata _data) onlyAdmin external payable returns (bool success) {
        success = _setImplementation(_newImplementation);

        if (_data.length > 0) {
            (success, ) = _newImplementation.delegatecall(_data);
            require(success, 'Proxy: UpgradeAndCall Fail');
        } else {
            require(msg.value == 0, 'Proxy: value must be 0');
        }
    }

    function setImplementation(address _newImplementation) onlyAdmin external virtual returns (bool) {
        return _setImplementation(_newImplementation);
    }

    function setAdmin(address _newAdmin) onlyAdmin external virtual returns (bool) {
        if (_newAdmin == address(0)) {
            revert InvalidAdmin(address(0));
        }

        emit ChangedAdmin(_admin(), _newAdmin);
        ProxyStorage.load().admin = _newAdmin;  
        return true;
    }

    function getImplementation() external view virtual returns (address) {
        return _implementation();
    }

    function getAdmin() external view virtual returns (address) {
        return _admin();
    }

    function _setImplementation(address _newImplementation) internal virtual returns (bool) {
        if (_newImplementation.code.length == 0) {
            revert InvalidImplementation(_newImplementation);
        }
        
        emit Upgraded(_newImplementation);
        ProxyStorage.load().implementation = _newImplementation;
        return true;
    }

    function _implementation() internal view override virtual returns (address) {
        return ProxyStorage.load().implementation;
    }

    function _admin() internal view virtual returns (address) {
        return ProxyStorage.load().admin;
    }

    /**
     * @notice 긴급 상황 시 관리자 개입을 위한 직접 호출 함수
     * @dev 예상치 못한 오류나 보안 이슈 발생 시 복구 목적으로만 사용
     *      프록시나 구현체에서 처리할 수 없는 긴급 상황 대응용
     * @param _target 호출할 대상 컨트랙트 주소
     * @param _calldata 실행할 함수의 calldata
     * @param _value 전송할 ETH 양 (wei 단위)
     */
    function ownerCall(address _target, bytes calldata _calldata, uint256 _value) external onlyAdmin payable {
        (bool success,) = _target.call{value: _value}(_calldata);
        
        require(success, 'Proxy: Owner Call Fail');
    }

    /**
     * @notice 오입금된 ERC20 토큰 회수 함수
     * @dev 실수로 프록시 컨트랙트에 전송된 토큰을 안전하게 회수
     *      정상적인 운영에서는 사용되지 않으며, 사용자 실수 복구용
     * @param _tokenAddr 회수할 토큰의 컨트랙트 주소
     * @param _recipient 토큰을 받을 주소
     * @param _amount 회수할 토큰 양
     */
    function withdrawToken(address _tokenAddr, address _recipient, uint256 _amount) external onlyAdmin {
        TransferHelper.safeTransfer(_tokenAddr, _recipient, _amount);

        emit Withdrawn(_tokenAddr, _recipient, _amount);
    }

    /**
     * @notice 오입금된 네이티브 코인(ETH) 회수 함수  
     * @dev 실수로 프록시 컨트랙트에 전송된 ETH를 안전하게 회수
     *      정상적인 운영에서는 사용되지 않으며, 사용자 실수 복구용
     * @param _recipient ETH를 받을 주소
     * @param _amount 회수할 ETH 양 (wei 단위)
     */
    function withdrawNative(address _recipient, uint256 _amount) external onlyAdmin {
        TransferHelper.safeTransferETH(_recipient, _amount);

        emit Withdrawn(nativeAddress, _recipient, _amount);
    }

}