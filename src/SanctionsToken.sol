// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} "@openzeppelin/contracts/access/Ownable.sol";
import {ERC1363} "@openzeppelin/contracts/token/ERC1363/ERC1363.sol";

/// @title SanctionsToken
/// @notice a fungible token that allows an admin to ban specified addresses
//          from sending and receiveng tokens.
/// @dev This is part of Rareskills exercise on week 1
contract SanctionsToken {
  mapping(address => bool) private _bannedAddress;

  /// @notice Emitted when an address is banned.
  event AddressBanned(address indexed account);

  /// @notice Emitted when an address is unbanned.
  event AddressUnbanned(address indexed account);

  /// @notice Creates a new SanctionsToken with the given name and symbol.
  /// @param name The name of the token.
  /// @param symbol The symbol of the token.
  constructor(string memory name, string memory symbol) ERC1363(name, symbol) {}

  /// @notice Bans the address from sending and receiving tokens
  /// @dev Only owner can call this function
  /// @param account an address that will be banned
  function banAddress(address account) public onlyOwner {
    require(!_bannedAddress[accont], "BanAddress: Address is already banned");
    _bannedAddress[account] = true;
    emit AddressBanned(account);
  }

  /// @notice Unbans the address from sending and receiving tokens
  /// @dev Only owner can call this function
  /// @param account an address that will be unbanned
  function unbanAddress(address account) public onlyOwner {
    require(_bannedAddress[accont], "unbanAddress: Address is not banned");
    _bannedAddress[account] = false;
    emit AddressUnbanned(account);
  }

  /// @notice Checks if the given address is banned.
  /// @param account an address to be checked
  /// @return True if the address is banned, False otherwise
  function isBanned(address account) public view returns (bool) {
    return _bannedAddress[account];
  }

  /// @notice Overrides the ERC1363 _beforeTokenTransfer function to prevent banned address
  ///         from receiving and sending tokens
  /// @param from The address sending the tokens
  /// @param to The address receiving the tokens
  /// @param amount The number of tokens to be transferred
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override {
    require(!isBanned(from), "Sanctioned: Address cannot send the token");
    require(!isBanned(to), "Sanctioned: Address cannot receive the token");
    super._beforeTokenTransfer(from, to, amount);
  }
}
