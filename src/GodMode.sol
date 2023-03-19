// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Token with god mode. A special address is able to transfer tokens
// between addresses at will
contract GodMode {
  uint256 public number;

  function setNumber(uint256 newNumber) public {
    number = newNumber;
  }

  function increment() public {
    number++;
  }
}
