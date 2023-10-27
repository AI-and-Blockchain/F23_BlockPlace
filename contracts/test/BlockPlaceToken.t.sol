// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.22;

import "forge-std/Test.sol";
import "../src/BlockPlaceToken.sol";

contract BlockPlaceTokenTest is Test {
    uint256 testNumber;

    function setUp() public {
        testNumber = 42;
    }

    function test_NumberIs42() public {
        assertEq(testNumber, 42);
    }
}
