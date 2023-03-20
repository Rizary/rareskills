// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC1363} from "@erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import {IERC1363Receiver} from
  "@erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import {IERC1363Spender} from
  "@erc1363-payable-token/contracts/token/ERC1363/IERC1363Spender.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title GodModeToken
/// @notice An ERC1363 token with a "god mode" feature, allowing a special address to transfer
/// tokens between any two addresses without any restrictions, with added security features.
contract GodModeToken is ERC20Burnable, ERC1363, Ownable {
  using EnumerableSet for EnumerableSet.AddressSet;

  EnumerableSet.AddressSet private gods;
  uint256 public godTransferDelay;
  mapping(address => uint256) public lastGodTransfer;

  /// @notice Initializes the token with the given parameters.
  /// @param name The name of the token.
  /// @param symbol The symbol of the token.
  /// @param _godTransferDelay The delay (in seconds) before the next godTransfer can be
  /// executed.
  constructor(
    string memory name,
    string memory symbol,
    uint256 _godTransferDelay
  ) ERC20(name, symbol) {
    godTransferDelay = _godTransferDelay;
  }

  /// @notice Minting function
  /// @dev Explain to a developer any extra details
  /// @param account address that received the token minted
  /// @param amount the amount of token minted
  function mint(address account, uint256 amount) external {
    super._mint(account, amount);
  }

  /// @notice Adds a new god address.
  /// @param _god The address that will be granted god mode permissions.

  function addGod(address _god) external onlyOwner {
    gods.add(_god);
  }

  /// @notice Removes a god address.
  /// @param _god The address to remove from the god mode permissions.
  function removeGod(address _god) external onlyOwner {
    gods.remove(_god);
  }

  /// @notice Checks if an address is a god.
  /// @param _god The address to check.
  /// @return True if the address is a god, false otherwise.
  function isGod(address _god) public view returns (bool) {
    return gods.contains(_god);
  }

  /// @notice Transfers tokens from one address to another using god mode.
  /// @param from The address to transfer tokens from.
  /// @param to The address to transfer tokens to.
  /// @param amount The amount of tokens to transfer.
  function godTransfer(address from, address to, uint256 amount) external {
    require(isGod(msg.sender), "GodModeToken: Caller is not a god address");
    require(
      block.timestamp + godTransferDelay >= lastGodTransfer[msg.sender] + godTransferDelay,
      "GodModeToken: Transfer delay not yet passed"
    );

    lastGodTransfer[msg.sender] = block.timestamp + godTransferDelay;
    _transfer(from, to, amount);
  }
}
