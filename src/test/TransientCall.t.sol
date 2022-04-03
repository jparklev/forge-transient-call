// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import { TransientCall } from "../TransientCall.sol";

contract SetAndRead {
    uint256 public value;

    function set(uint256 _value) public {
        value = _value;
    }

    function read() public view returns (uint256) {
        return value;
    }

    function setAndRead(uint256 _value) public returns (uint256) {
        value = _value;
        return value;
    }

    function setAndRevert(uint256 _value) public returns (uint256) {
        value = _value;
        revert("CALL_FAILED");
    }
}

contract TransientCallTest is DSTest, TransientCall {
    SetAndRead public setAndRead;

    function setUp() public {
        setAndRead = new SetAndRead();
    }

    function testFirstCallDeploys() public {
        assertTrue(address(_transientCallInner) == address(0));
        transientCall(address(setAndRead), abi.encodeWithSelector(SetAndRead.read.selector));
        assertTrue(address(_transientCallInner) != address(0));
    }

    function testReadsAndRevertsChanges() public {
        bytes memory retData = transientCall(
            address(setAndRead),
            abi.encodeWithSelector(SetAndRead.setAndRead.selector, 555)
        );
        uint256 readValue = abi.decode(retData, (uint256));
        assertEq(readValue, 555);

        // State change was reverted
        assertEq(setAndRead.value(), 0);
    }

    // function testForwardsRevertMessages() public {
    //     vm.
    //     bytes memory retData = transientCall(
    //         address(setAndRead),
    //         abi.encodeWithSelector(SetAndRead.setAndRevert.selector, 555)
    //     );
    // }
}