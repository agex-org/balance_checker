// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MintableERC20 is ERC20 {
	uint8 private _decimals;

	constructor(string memory name, string memory symbol, uint8 decimals_) ERC20(name, symbol) {
		_decimals = decimals_;
	}

	function mint(address recipient, uint256 amount) public {
		_mint(recipient, amount * 10 ** decimals());
	}

	function decimals() public view override returns (uint8) {
		return _decimals;
	}
}
