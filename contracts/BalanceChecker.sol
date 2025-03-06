// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ERC20 contract interface
interface Token {
    function balanceOf(address) external view returns (uint256);
}

contract BalanceChecker {
    /* Fallback function, don't accept any ETH */
    fallback() external payable {
        revert("BalanceChecker does not accept payments");
    }

    receive() external payable {
        revert("BalanceChecker does not accept payments");
    }

    struct BalanceInfo {
        address user;
        address token;
        uint256 balance;
        uint256 blockNumber;
        uint256 blockTimestamp;
    }

    struct BalanceRequest {
        address user;
        address token;
    }

    function tokenBalance(address user, address token)
    private
    view
    returns (uint256)
    {
        uint256 tokenCode;
        assembly {
            tokenCode := extcodesize(token)
        }

        if (tokenCode > 0) {
            try Token(token).balanceOf(user) returns (uint256 balance) {
                return balance;
            } catch {
                return 0;
            }
        } else {
            return 0;
        }
    }

    /*
        Check the token balances of a wallet for multiple tokens.
        Returns an array of BalanceInfo structs, each containing the user, token, and balance.
    */
    function getAllTokensBalances(address[] calldata users, address[] calldata tokens)
    external
    view
    returns (BalanceInfo[] memory)
    {
        BalanceInfo[] memory addrBalances = new BalanceInfo[](
            tokens.length * users.length
        );

        uint256 currentBlockNumber = block.number;
        uint256 currentBlockTimestamp = block.timestamp;

        uint256 index = 0;
        for (uint256 i = 0; i < users.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                uint256 balance;
                if (tokens[j] != address(0)) {
                    balance = tokenBalance(users[i], tokens[j]);
                } else {
                    balance = users[i].balance; // ETH balance
                }
                addrBalances[index] = BalanceInfo({
                    user: users[i],
                    token: tokens[j],
                    balance: balance,
                    blockNumber: currentBlockNumber,
                    blockTimestamp: currentBlockTimestamp
                });
                index++;
            }
        }

        return addrBalances;
    }

    /**
     * @notice Fetches the balances for specific user-token pairs.
     * @param requests An array of BalanceRequest structs, each containing a user and token address.
     *                 If the token address is `address(0)`, the function retrieves the ETH balance of the user.
     * @return balances An array of BalanceInfo structs with each user-token pair and the associated balance.
     */
    function getSelectedTokenBalances(BalanceRequest[] calldata requests)
    external
    view
    returns (BalanceInfo[] memory)
    {
        BalanceInfo[] memory balances = new BalanceInfo[](requests.length);

        uint256 currentBlockNumber = block.number;
        uint256 currentBlockTimestamp = block.timestamp;


        for (uint256 i = 0; i < requests.length; i++) {
            address user = requests[i].user;
            address token = requests[i].token;
            uint256 balance;

            if (token != address(0)) {
                balance = tokenBalance(user, token); // Get token balance
            } else {
                balance = user.balance; // Get ETH balance
            }

            balances[i] = BalanceInfo({
                user: user,
                token: token,
                balance: balance,
                blockNumber: currentBlockNumber,
                blockTimestamp: currentBlockTimestamp
            });
        }

        return balances;
    }
}
