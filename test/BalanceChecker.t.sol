// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {BalanceChecker} from "contracts/BalanceChecker.sol";
import {MintableERC20} from "contracts/mocks/MintableERC20.sol";

contract BalanceCheckerTest is Test {
    address public balanceCheckerAddress = 0xFe42B641bD4489E28914756Be84f2a7E2dF8Ab2B;
    BalanceChecker public balanceChecker;
    MintableERC20 public testToken;

    // Test users
    address public user1 = address(0x123);
    address public user2 = address(0x456);

    function setUp() public {
        // Create a fork using sonic_rpc endpoint at a specific block
        vm.createSelectFork(vm.rpcUrl("sonic_rpc"), 9_407_730);

        // Create BalanceChecker contract instance
        balanceChecker = BalanceChecker(payable(balanceCheckerAddress));

        // Deploy MintableERC20 contract
        testToken = new MintableERC20("Test Token", "TEST", 18);

        // Mint tokens for users
        testToken.mint(user1, 100);
        testToken.mint(user2, 200);

        // Set ETH balances for users
        vm.deal(user1, 1 ether);
        vm.deal(user2, 2 ether);
    }

    function testGetAllTokensBalances() public {
        // Prepare arrays for users and tokens.
        // For tokens, we use testToken and the zero address (to represent ETH).
        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user2;

        address[] memory tokens = new address[](2);
        tokens[0] = address(testToken); // ERC20 token balance
        tokens[1] = address(0);         // ETH balance

        // Call the batch balance function
        BalanceChecker.BalanceInfo[] memory infos = balanceChecker.getAllTokensBalances(users, tokens);

        // There should be 4 entries (2 users x 2 tokens).
        // Expected order:
        // infos[0] -> user1, testToken
        // infos[1] -> user1, ETH
        // infos[2] -> user2, testToken
        // infos[3] -> user2, ETH

        uint256 tokenDecimals = testToken.decimals();
        uint256 expectedUser1TokenBalance = 100 * (10 ** tokenDecimals);
        uint256 expectedUser2TokenBalance = 200 * (10 ** tokenDecimals);

        // Validate the first user's token balance
        assertEq(infos[0].user, user1, "First entry: user mismatch");
        assertEq(infos[0].token, address(testToken), "First entry: token mismatch");
        assertEq(infos[0].balance, expectedUser1TokenBalance, "User1 token balance incorrect");

        // Validate the first user's ETH balance
        assertEq(infos[1].user, user1, "Second entry: user mismatch");
        assertEq(infos[1].token, address(0), "Second entry: token mismatch (ETH)");
        assertEq(infos[1].balance, 1 ether, "User1 ETH balance incorrect");

        // Validate the second user's token balance
        assertEq(infos[2].user, user2, "Third entry: user mismatch");
        assertEq(infos[2].token, address(testToken), "Third entry: token mismatch");
        assertEq(infos[2].balance, expectedUser2TokenBalance, "User2 token balance incorrect");

        // Validate the second user's ETH balance
        assertEq(infos[3].user, user2, "Fourth entry: user mismatch");
        assertEq(infos[3].token, address(0), "Fourth entry: token mismatch (ETH)");
        assertEq(infos[3].balance, 2 ether, "User2 ETH balance incorrect");

        // Optionally, also verify the block number and timestamp in the returned structs.
        uint256 currentBlockNumber = block.number;
        uint256 currentBlockTimestamp = block.timestamp;
        assertEq(infos[0].blockNumber, currentBlockNumber, "Block number mismatch");
        assertEq(infos[0].blockTimestamp, currentBlockTimestamp, "Block timestamp mismatch");
    }

    function testGetSelectedTokenBalances() public {
        // Prepare an array of BalanceRequest structs.
        BalanceChecker.BalanceRequest[] memory requests = new BalanceChecker.BalanceRequest[](4);
        requests[0] = BalanceChecker.BalanceRequest({user: user1, token: address(testToken)});
        requests[1] = BalanceChecker.BalanceRequest({user: user1, token: address(0)});
        requests[2] = BalanceChecker.BalanceRequest({user: user2, token: address(testToken)});
        requests[3] = BalanceChecker.BalanceRequest({user: user2, token: address(0)});

        // Call the selective balance function
        BalanceChecker.BalanceInfo[] memory infos = balanceChecker.getSelectedTokenBalances(requests);

        uint256 tokenDecimals = testToken.decimals();
        uint256 expectedUser1TokenBalance = 100 * (10 ** tokenDecimals);
        uint256 expectedUser2TokenBalance = 200 * (10 ** tokenDecimals);

        // Validate each returned BalanceInfo
        assertEq(infos[0].user, user1, "First request: user mismatch");
        assertEq(infos[0].token, address(testToken), "First request: token mismatch");
        assertEq(infos[0].balance, expectedUser1TokenBalance, "User1 token balance incorrect");

        assertEq(infos[1].user, user1, "Second request: user mismatch");
        assertEq(infos[1].token, address(0), "Second request: token mismatch (ETH)");
        assertEq(infos[1].balance, 1 ether, "User1 ETH balance incorrect");

        assertEq(infos[2].user, user2, "Third request: user mismatch");
        assertEq(infos[2].token, address(testToken), "Third request: token mismatch");
        assertEq(infos[2].balance, expectedUser2TokenBalance, "User2 token balance incorrect");

        assertEq(infos[3].user, user2, "Fourth request: user mismatch");
        assertEq(infos[3].token, address(0), "Fourth request: token mismatch (ETH)");
        assertEq(infos[3].balance, 2 ether, "User2 ETH balance incorrect");

        // Verify the block number and timestamp as well.
        uint256 currentBlockNumber = block.number;
        uint256 currentBlockTimestamp = block.timestamp;
        assertEq(infos[0].blockNumber, currentBlockNumber, "Block number mismatch");
        assertEq(infos[0].blockTimestamp, currentBlockTimestamp, "Block timestamp mismatch");
    }

    function testReceiveETHReverts() public {
        // Ensure that sending ETH directly to the BalanceChecker reverts.
        vm.expectRevert(bytes("BalanceChecker does not accept payments"));
        (bool success, ) = address(balanceChecker).call{value: 0.1 ether}("");
        require(!success, "BalanceChecker should not accept ETH payments");
    }

    function testFallbackETHReverts() public {
        // Sending ETH with arbitrary data should also revert.
        vm.expectRevert(bytes("BalanceChecker does not accept payments"));
        (bool success, ) = address(balanceChecker).call{value: 0.1 ether}(hex"deadbeef");
        require(!success, "BalanceChecker fallback should not accept ETH payments");
    }

    function testInvalidTokenAddress() public {
        // Test getSelectedTokenBalances with a token address that has no code.
        BalanceChecker.BalanceRequest[] memory requests = new BalanceChecker.BalanceRequest[](1);
        // Using user1 as the token address since it's an EOA (has no code)
        requests[0] = BalanceChecker.BalanceRequest({user: user1, token: user1});

        BalanceChecker.BalanceInfo[] memory infos = balanceChecker.getSelectedTokenBalances(requests);
        // Since user1 is not a contract, balanceChecker.tokenBalance should return 0.
        assertEq(infos[0].balance, 0, "Balance for invalid token should be 0");
    }
}