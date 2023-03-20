// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC1363} from "@erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import {IERC1363Receiver} from
  "@erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import {IERC1363Spender} from
  "@erc1363-payable-token/contracts/token/ERC1363/IERC1363Spender.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title BondingCurveToken
/// @notice An ERC1363 token with a linear bonding curve for token sales and buybacks.
contract BondingCurveToken is ERC20Burnable, ERC1363, IERC1363Receiver, Ownable {
  using SafeMath for uint256;
  using Address for address;

  uint256 public constant M = 10 ** 15; // slope
  uint256 public constant B = 0;

  event ReceivedEther(address sender, uint256 value);
  // Add a payable receive() function to accept Ether

  receive() external payable {
    emit ReceivedEther(msg.sender, msg.value);
  }

  /// @notice Initializes the token with the given parameters.
  /// @param name The name of the token.
  /// @param symbol The symbol of the token.
  constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

  /// @notice Minting function
  /// @dev Explain to a developer any extra details
  /// @param account address that received the token minted
  /// @param amount the amount of token minted
  function mint(address account, uint256 amount) external {
    super._mint(account, amount);
  }

  /// @notice Buys tokens using Ether and the linear bonding curve.
  function buy() external payable {
    uint256 currentSupply = totalSupply();
    uint256 etherAmount = msg.value;
    uint256 newSupply = calculateNewSupply(currentSupply, etherAmount);

    uint256 tokensBought = newSupply.sub(currentSupply);
    _mint(msg.sender, tokensBought);
  }
  /// @notice Sells tokens back to the contract and receives Ether according to the linear
  /// bonding curve.
  /// @param amount The amount of tokens to sell.

  function sell(uint256 amount) external {
    uint256 currentSupply = totalSupply();
    uint256 etherAmount = calculateEtherAmountToReceive(currentSupply.sub(amount), amount);

    _burn(msg.sender, amount);
    Address.sendValue(payable(msg.sender), etherAmount);
  }

  /// @notice Calculates the new token supply after a user buys tokens with the given Ether
  /// amount.
  /// @param currentSupply The current total supply of tokens.
  /// @param etherAmount The Ether amount to spend.
  /// @return The new total supply of tokens.
  function calculateNewSupply(
    uint256 currentSupply,
    uint256 etherAmount
  ) public pure returns (uint256) {
    uint256 delta =
      sqrt(currentSupply ** 2 + (etherAmount.mul(2e18).div(M))).sub(currentSupply);
    uint256 newSupply = currentSupply.add(delta);
    return newSupply;
  }

  /// @notice Calculates the Ether amount to receive when selling a given amount of tokens.
  /// @param currentSupply The current total supply of tokens after burning the sold amount.
  /// @param tokenAmount The amount of tokens to sell.
  /// @return The Ether amount to receive.
  function calculateEtherAmountToReceive(
    uint256 currentSupply,
    uint256 tokenAmount
  ) public pure returns (uint256) {
    uint256 price = M.mul(currentSupply).add(B);
    uint256 etherAmount = tokenAmount.mul(price).div(1e18);
    return etherAmount;
  }

  /// @notice ERC1363 implementation to trigger the `buy` or `sell` function on token received.
  /// @param operator The address that called the `transfer` or `transferFrom` function.
  /// @param from The address which previous tokens are taken.
  /// @param value The amount of tokens sent.
  /// @param data Additional data with no specified format. If data is empty, triggers the
  /// `buy` function. If data is non-empty, triggers the `sell` function.
  /// @return A bytes4 value that indicates the function has been successfully executed.
  function onTransferReceived(
    address operator,
    address from,
    uint256 value,
    bytes calldata data
  ) external override returns (bytes4) {
    require(
      msg.sender == address(this), "BondingCurveToken: Transfer must come from this contract"
    );

    // Check if the function is being triggered by a token purchase (buy) or a token sale
    // (sell)
    if (data.length == 0) {
      this.buy();
    } else {
      uint256 amount = abi.decode(data, (uint256));
      this.sell(amount);
    }

    return this.onTransferReceived.selector;
  }

  function sqrt(uint256 x) internal pure returns (uint256) {
    if (x == 0) return 0;

    uint256 z = (x + 1) / 2;
    uint256 y = x;

    while (z < y) {
      y = z;
      z = (x / z + z) / 2;
    }

    return y;
  }
}
