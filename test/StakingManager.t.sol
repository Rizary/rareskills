// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {StakingManager} from "../src/StakingManager.sol";
import {StakingToken} from "../src/StakingToken.sol";
import {PresaleNFT} from "../src/PresaleNFT.sol";

contract StakingManagerTest is Test {
  PresaleNFT presaleNFT;
  StakingToken stakingToken;
  StakingManager stakingManager;
  uint256 private tokenPrice;
  address addr1 = address(0x123);

  function setUp() public {
    presaleNFT = new PresaleNFT();
    stakingToken = new StakingToken();
    stakingManager = new StakingManager(
            presaleNFT,
            address(stakingToken),
            1_666_666_666_666_666,
            1_000_000
        );
    tokenPrice = 20 ether;
    vm.roll(1);
  }

  function mintAndApprove(uint256 startId, uint256 endId) internal {
    for (uint256 i = startId; i <= endId; i++) {
      presaleNFT.publicMint{value: presaleNFT.PRICE()}();
      presaleNFT.approve(address(stakingManager), i);
    }
  }

  /// @notice check whether tokenId already deposited
  function isTokenIdDeposited(address account, uint256 tokenId) internal view returns (bool) {
    uint256[] memory depositedTokenIds = stakingManager.depositsOf(account);

    for (uint256 i = 0; i < depositedTokenIds.length; i++) {
      if (depositedTokenIds[i] == tokenId) {
        return true;
      }
    }

    return false;
  }

  function testDeposit() public {
    uint256[] memory tokenIds = new uint256[](3);
    tokenIds[0] = 1;
    tokenIds[1] = 2;
    tokenIds[2] = 3;
    vm.prank(address(this));
    stakingManager.unpause();

    vm.startPrank(addr1, addr1);
    vm.deal(addr1, tokenPrice);
    mintAndApprove(1, 5);
    stakingManager.deposit(tokenIds);

    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertTrue(isTokenIdDeposited(addr1, tokenIds[i]), "Token should be deposited");
    }
    vm.stopPrank();
  }

  function testCalculateReward() public {
    uint256[] memory tokenIds = new uint256[](3);
    tokenIds[0] = 1;
    tokenIds[1] = 2;
    tokenIds[2] = 3;
    vm.prank(address(this));
    stakingManager.unpause();

    vm.startPrank(addr1, addr1);
    vm.deal(addr1, tokenPrice);
    mintAndApprove(1, 5);
    stakingManager.deposit(tokenIds);

    vm.roll(block.number + 100);

    uint256 expectedReward = 100 * 1_666_666_666_666_666;
    uint256 reward = stakingManager.calculateReward(addr1, tokenIds[0]);
    vm.stopPrank();
    assertEq(reward, expectedReward, "Calculated reward should match the expected reward");
  }

  function testClaimRewards() public {
    uint256[] memory tokenIds = new uint256[](3);
    tokenIds[0] = 1;
    tokenIds[1] = 2;
    tokenIds[2] = 3;
    vm.prank(address(this));
    stakingManager.unpause();

    vm.startPrank(addr1, addr1);
    vm.deal(addr1, tokenPrice);
    mintAndApprove(1, 5);
    stakingManager.deposit(tokenIds);
    assertEq(3, presaleNFT.balanceOf(address(stakingManager)), "Balance not greater than zero");

    vm.roll(block.number + 100);

    uint256 initialBalance = stakingToken.balanceOf(addr1);
    stakingManager.claimRewards(tokenIds);
    uint256 finalBalance = stakingToken.balanceOf(addr1);

    uint256 expectedReward = 100 * 1_666_666_666_666_666 * 3;
    uint256 claimedReward = finalBalance - initialBalance;
    vm.stopPrank();
    assertEq(claimedReward, expectedReward, "Claimed reward should match the expected reward");
  }

  function testWithdraw() public {
    uint256[] memory tokenIds = new uint256[](3);
    tokenIds[0] = 1;
    tokenIds[1] = 2;
    tokenIds[2] = 3;
    vm.prank(address(this));
    stakingManager.unpause();

    vm.startPrank(addr1, addr1);
    vm.deal(addr1, tokenPrice);
    mintAndApprove(1, 5);
    stakingManager.deposit(tokenIds);

    vm.roll(block.number + 100);

    stakingManager.withdraw(tokenIds);
    for (uint256 i = 0; i < tokenIds.length; i++) {
      assertEq(presaleNFT.ownerOf(tokenIds[i]), addr1);
      assertFalse(isTokenIdDeposited(addr1, tokenIds[i]));
    }
    vm.stopPrank();
  }
}
