// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BalanceChecker} from "contracts/BalanceChecker.sol";
import {MintableERC20} from "contracts/mocks/MintableERC20.sol";

contract CounterTest is Test {
    address public balanceCheckerAddress = 0xFe42B641bD4489E28914756Be84f2a7E2dF8Ab2B;
    BalanceChecker public balanceChecker;
    MintableERC20 public testToken;

    // Test users
    address public user1 = address(0x123);
    address public user2 = address(0x456);

    function setUp() public {
        // Create a fork
        vm.createSelectFork(vm.rpcUrl("sonic_rpc"), 9_407_730);

        // Deploy the contracts
        balanceChecker = BalanceChecker(payable(balanceCheckerAddress));

        // Deploy MintableERC20 contract
        testToken = new MintableERC20("Test Token", "TEST", 18);

        // mint token for the users
        testToken.mint(user1, 100);
        testToken.mint(user2, 200);
    }

    function testGetAllTokensBalances() public {
        // Prepare arrays for users and tokens.
        // For tokens, we use testToken and the zero address (to represent ETH).
        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user2;

        address[] memory tokens = new address[](2);
        tokens[0] = address(testToken); // ERC20 token balance
        tokens[1] = address(0); // ETH balance

        // Call the batch balance function
        BalanceChecker.BalanceInfo[] memory infos = balanceChecker.getAllTokensBalances(users, tokens);

        // The returned array length is users.length * tokens.length = 4.
        // Expected order:
        // infos[0] -> user1, testToken
        // infos[1] -> user1, ETH
        // infos[2] -> user2, testToken
        // infos[3] -> user2, ETH

        // Verify token balances from the dummy token.
        assertEq(infos[0].balance, 100, "User1 token balance should be 100");
        // Verify ETH balance using vm.deal (user1 should have 1 ether).
        assertEq(infos[1].balance, 1 ether, "User1 ETH balance should be 1 ether");
        assertEq(infos[2].balance, 200, "User2 token balance should be 200");
        assertEq(infos[3].balance, 2 ether, "User2 ETH balance should be 2 ether");
    }
}
