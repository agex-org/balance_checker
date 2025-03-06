// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BalanceChecker} from "contracts/BalanceChecker.sol";

contract CounterTest is Test {
    BalanceChecker public balanceChecker;

    function setUp() public {
        balanceChecker = new BalanceChecker();
    }
}
