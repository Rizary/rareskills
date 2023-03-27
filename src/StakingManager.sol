/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Enumerable} from
  "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {StakingToken} from "./StakingToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title StakingManager
/// @notice This contract manage NFT staking feature and its rewards
contract StakingManager is Ownable, IERC721Receiver, ReentrancyGuard, Pausable {
  using EnumerableSet for EnumerableSet.UintSet;

  //uint256's
  uint256 public expiration;
  //rate governs how often you receive your token
  uint256 public rate;

  // mappings
  mapping(uint256 => address) public originalOwner;
  mapping(address => EnumerableSet.UintSet) private _deposits;
  mapping(address => mapping(uint256 => uint256)) public _depositBlocks;

  IERC721 public itemNFT;
  StakingToken public tokenRewards;
  address nullAddress = 0x0000000000000000000000000000000000000000;

  constructor(IERC721 _nft, address _rewards, uint256 _rate, uint256 _expiration) {
    itemNFT = _nft;
    tokenRewards = StakingToken(_rewards);
    rate = _rate;
    expiration = block.number + _expiration;
    _pause();
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  /* STAKING MECHANICS */

  /// @notice
  // 5 $STKN PER DAY
  // n Blocks per day = 6000, Token Decimal = 18
  // Rate = 833333333333333
  /// @notice Set a multiplier for how many tokens to earn each time a block passes.
  /// @dev The formula (assuming per day) :
  ///      `rate = (X $STKN * 10^TokenDecimal) / n blocks per day`
  /// @param _rate new rate
  function setRate(uint256 _rate) public onlyOwner {
    rate = _rate;
  }

  /// @notice Set this to a block to disable the ability to continue accruing tokens past that
  /// block number.
  function setExpiration(uint256 _expiration) public onlyOwner {
    expiration = block.number + _expiration;
  }

  /// @notice check deposit amount.
  function depositsOf(address account) external view returns (uint256[] memory) {
    EnumerableSet.UintSet storage depositSet = _deposits[account];
    uint256[] memory tokenIds = new uint256[] (depositSet.length());

    for (uint256 i; i < depositSet.length(); i++) {
      tokenIds[i] = depositSet.at(i);
    }

    return tokenIds;
  }

  /// @notice reward amount by address/tokenIds[]
  function calculateRewards(
    address account,
    uint256[] memory tokenIds
  ) public view returns (uint256[] memory rewards) {
    rewards = new uint256[](tokenIds.length);

    for (uint256 i; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];
      rewards[i] = rate * (_deposits[account].contains(tokenId) ? 1 : 0)
        * (Math.min(block.number, expiration) - _depositBlocks[account][tokenId]);
    }

    return rewards;
  }

  /// @notice reward amount by address/tokenId - Tested
  function calculateReward(address account, uint256 tokenId) public view returns (uint256) {
    require(
      Math.min(block.number, expiration) > _depositBlocks[account][tokenId], "Invalid blocks"
    );
    return rate * (_deposits[account].contains(tokenId) ? 1 : 0)
      * (Math.min(block.number, expiration) - _depositBlocks[account][tokenId]);
  }

  /// @notice reward claim function - Tested
  function claimRewards(uint256[] calldata tokenIds) public whenNotPaused {
    uint256 reward;
    uint256 blockCur = Math.min(block.number, expiration);

    for (uint256 i; i < tokenIds.length; i++) {
      reward += calculateReward(msg.sender, tokenIds[i]);
      _depositBlocks[msg.sender][tokenIds[i]] = blockCur;
    }

    if (reward > 0) {
      tokenRewards.mint(msg.sender, reward);
    }
  }

  /// @notice deposit all NFTs to StakingManager contract address
  function deposit(uint256[] calldata tokenIds) external whenNotPaused {
    require(msg.sender != address(itemNFT), "Invalid address");
    claimRewards(tokenIds);

    for (uint256 i; i < tokenIds.length; i++) {
      itemNFT.safeTransferFrom(msg.sender, address(this), tokenIds[i], "");
      _deposits[msg.sender].add(tokenIds[i]);
    }
  }

  //withdrawal function. Tested
  function withdraw(uint256[] calldata tokenIds) external whenNotPaused nonReentrant {
    claimRewards(tokenIds);
    for (uint256 i; i < tokenIds.length; i++) {
      require(msg.sender == originalOwner[tokenIds[i]], "address is not the token owner");
      require(_deposits[msg.sender].contains(tokenIds[i]), "Staking: token not deposited");
      _deposits[msg.sender].remove(tokenIds[i]);
      itemNFT.safeTransferFrom(address(this), msg.sender, tokenIds[i], "");
    }
  }

  //withdrawal function.
  function withdrawTokens() external onlyOwner {
    uint256 tokenSupply = tokenRewards.balanceOf(address(this));
    tokenRewards.transfer(msg.sender, tokenSupply);
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
    originalOwner[tokenId] = from;
    return IERC721Receiver.onERC721Received.selector;
  }
}
