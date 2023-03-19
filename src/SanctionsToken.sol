// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC1363} from "@erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import {IERC1363Spender} from
  "@erc1363-payable-token/contracts/token/ERC1363/IERC1363Spender.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title SanctionsToken
/// @notice a fungible token that allows an admin to ban specified addresses
//          from sending and receiveng tokens.
/// @dev This is part of Rareskills exercise on week 1
contract SanctionsToken is ERC1363, IERC1363Spender, Ownable {
  mapping(address => bool) private _bannedAddress;

  /// @notice Emitted when an address is banned.
  event AddressBanned(address indexed account);

  /// @notice Emitted when an address is unbanned.
  event AddressUnbanned(address indexed account);

  /// @notice Creates a new SanctionsToken with the given name and symbol.
  /// @param name The name of the token.
  /// @param symbol The symbol of the token.
  constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

  /// @notice Minting function
  /// @dev Explain to a developer any extra details
  /// @param account address that received the token minted
  /// @param amount the amount of token minted
  function mint(address account, uint256 amount) public {
    super._mint(account, amount);
  }

  /// @notice Burning function
  /// @dev Explain to a developer any extra details
  /// @param account address to burn the token from
  /// @param amount the amount of token burn
  function burn(address account, uint256 amount) public {
    require(!isBanned(account), "Sanctioned: Address cannot burn the token");
    super._burn(account, amount);
  }

  /// @notice Bans the address from sending and receiving tokens
  /// @dev Only owner can call this function
  /// @param account an address that will be banned
  function banAddress(address account) public onlyOwner {
    require(!_bannedAddress[account], "BanAddress: Address is already banned");
    _bannedAddress[account] = true;
    emit AddressBanned(account);
  }

  /// @notice Unbans the address from sending and receiving tokens
  /// @dev Only owner can call this function
  /// @param account an address that will be unbanned
  function unbanAddress(address account) public onlyOwner {
    require(_bannedAddress[account], "unbanAddress: Address is not banned");
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

  /// @notice Overrides the ERC1363Spender onApprovalReceived function
  /// to prevent banned address from receiving and sending tokens
  /// @param sender The address sending the tokens
  /// @param amount The amount approved
  /// @param data bytes additional data with no specified format
  function onApprovalReceived(
    address sender,
    uint256 amount,
    bytes calldata data
  ) external override returns (bytes4) {
    require(!isBanned(sender), "Sanctioned: Address cannot send the token");
    return bytes4(data);
  }
}
