/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/// @title StakingToken
/// @notice This is the NFT staking rewards token contract
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingToken is ERC20, Pausable, Ownable {
  constructor() ERC20("StakingToken", "STKN") {}

  /// @notice pause minting token
  function pause() public onlyOwner {
    _pause();
  }

  /// @notice unpause minting token
  function unpause() public onlyOwner {
    _unpause();
  }

  /// @notice minting token
  function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
  }

  /// @notice execute before token transfer
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal override whenNotPaused {
    super._beforeTokenTransfer(from, to, amount);
  }
}
