// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.9.0;

contract TransientCall {
    TransientCallInner public _transientCallInner;

    function transientCall(address target, bytes memory callData) public returns (bytes memory) {
        if (_transientCallInner == TransientCallInner(address(0))) _transientCallInner = new TransientCallInner();

        try _transientCallInner.callRevert(target, callData) returns (string memory rvtMessage) {
            revert(rvtMessage);
        } catch Error(string memory retData) {
            return bytes(retData);
        }
    }
}

contract TransientCallInner {
    error TransientCallFailed();

    function callRevert(address target, bytes memory callData) external returns (string memory) {
        (bool success, bytes memory retData) = target.call(callData);
        // Reverse the logic of a normal call by returning on reverts and reverting with return data on success
        if (!success) {
            if (retData.length < 68) return '';

            assembly {
                retData := add(retData, 0x04)
            }
            return abi.decode(retData, (string));
        }

        revert(string(retData));
    }
}
