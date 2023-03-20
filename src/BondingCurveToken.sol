// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Token sale and buyback with bonding curve. The more tokens a user buys,
// the more expensive the token becomes. To keep things simple, use a linear
// bonding curve. When a person sends a token to the contract with ERC1363, it
// should trigger the receive function.
contract BondingCurveToken {
  uint256 public number;

  function setNumber(uint256 newNumber) public {
    number = newNumber;
  }

  function increment() public {
    number++;
  }
}
