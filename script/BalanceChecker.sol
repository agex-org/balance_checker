// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BalanceChecker} from "contracts/BalanceChecker.sol";

contract BalanceCheckerScript is Script {
	BalanceChecker public balanceChecker;
	function setUp() public {}
	function run() public {
		vm.startBroadcast();
		balanceChecker = new BalanceChecker();
		vm.stopBroadcast();
	}
}