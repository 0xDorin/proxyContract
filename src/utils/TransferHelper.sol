// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.20;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address _token,
        address _to,
        uint256 _value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0x095ea7b3, _to, _value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper: approve failed'
        );
    }

    function safeTransfer(
        address _token,
        address _to,
        uint256 _value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0xa9059cbb, _to, _value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper: transfer failed'
        );
    }

    function safeTransferFrom(
        address _token,
        address from,
        address _to,
        uint256 _value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0x23b872dd, from, _to, _value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper: transferFrom failed'
        );
    }

    function safeTransferETH(address _to, uint256 _value) internal {
        (bool success, ) = _to.call{value: _value}(new bytes(0));
        require(success, 'TransferHelper: ETH transfer failed');
    }   
}