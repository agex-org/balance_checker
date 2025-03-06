# BalanceChecker & Agex Project Integration

## What is BalanceChecker?

**BalanceChecker** is a Solidity smart contract designed to efficiently retrieve the ETH and ERC20 token balances for one or more addresses with a single on-chain call. It offers two primary functions:

- **`getAllTokensBalances`**: Accepts arrays of user addresses and token addresses (with `address(0)` representing ETH) and returns an array of `BalanceInfo` structs. Each struct includes:
    - `user`: The address queried.
    - `token`: The token address (or zero for ETH).
    - `balance`: The balance of the token or ETH.
    - `blockNumber` & `blockTimestamp`: The block details at the time of the query.

- **`getSelectedTokenBalances`**: Accepts an array of `BalanceRequest` structs for specific user-token pairs and returns their corresponding balance information.

The contract ensures robustness by:
- Checking if a token address is a contract (using `extcodesize` in assembly) before attempting to call `balanceOf`.
- Reverting any ETH transfers via its `fallback` and `receive` functions, which helps prevent accidental transfers.



## How to Use BalanceChecker

1. **Deployment:**  
   Deploy the BalanceChecker contract on your preferred Ethereum-compatible network.

2. **Querying Balances:**
    - **Batch Querying:**  
      Use `getAllTokensBalances` to fetch both ETH and token balances for multiple addresses:
      ```solidity
      address[] memory users = new address[](2);
      users[0] = 0x123...;
      users[1] = 0x456...;
 
      address[] memory tokens = new address[](2);
      tokens[0] = tokenAddress; // ERC20 token address
      tokens[1] = address(0);   // ETH balance
 
      BalanceChecker.BalanceInfo[] memory results = balanceChecker.getAllTokensBalances(users, tokens);
      ```
    - **Selective Querying:**  
      Use `getSelectedTokenBalances` if you need balances for specific user-token pairs:
      ```solidity
      BalanceChecker.BalanceRequest[] memory requests = new BalanceChecker.BalanceRequest[](1);
      requests[0] = BalanceChecker.BalanceRequest({user: 0x123..., token: tokenAddress});
      BalanceChecker.BalanceInfo[] memory result = balanceChecker.getSelectedTokenBalances(requests);
      ```

## How Agex Uses BalanceChecker

In the Agex project, the BalanceChecker contract is integrated into the backend via the **BatchBalanceService** written in Python. This service leverages Web3.py to interact with the deployed contract and fetch token balances in a single batch call.

### BatchBalanceService

- **Connection Setup:**  
  The service initializes a Web3 connection with the provided RPC endpoint and loads the contract using its ABI and deployed address.

- **Fetching Balances:**  
  The `get_batch_balance` method accepts an address, converts it to checksum format, and calls the contract’s `getAllTokensBalances` function.


## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Deploy

```shell
$ forge script script/BalanceChecker.s.sol:BalanceCheckerScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


### Dependency
```bash
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```