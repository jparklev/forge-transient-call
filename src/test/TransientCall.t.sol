// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import { DSTest } from "ds-test/test.sol";
import { Vm } from "forge-std/Vm.sol";

import { TransientCall } from "../TransientCall.sol";

contract MockStore {
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

    function revertWithMessage(string memory message) public pure {
        require(false, message);
    }
}

contract TransientCallTest is DSTest, TransientCall {
    Vm internal constant vm = Vm(HEVM_ADDRESS);

    MockStore public mockStore;

    function setUp() public {
        mockStore = new MockStore();
    }

    function testReadsAndRevertsChanges() public {
        uint256 VALUE_TO_SET = 555;
        bytes memory retData = this.transientCall(
            address(mockStore),
            abi.encodeWithSelector(MockStore.setAndRead.selector, VALUE_TO_SET)
        );

        uint256 readValue = abi.decode(retData, (uint256));

        assertEq(readValue, VALUE_TO_SET);
        // State change was reverted
        assertEq(mockStore.value(), 0);
    }

    function testForwardsRevertMessages() public {
        vm.expectRevert("CALL_FAILED");
        this.transientCall(
            address(mockStore),
            abi.encodeWithSelector(MockStore.revertWithMessage.selector, "CALL_FAILED")
        );
    }
}