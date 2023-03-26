// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {StakingToken} from "../src/StakingToken.sol";

contract StakingTokenTest is Test {
  StakingToken stakingToken;

  function setUp() public {
    stakingToken = new StakingToken();
  }

  function testMintToken() public {
    stakingToken.mint(address(this), 1000 * 10 ** 18);
    assertEq(stakingToken.balanceOf(address(this)), 1000 * 10 ** 18);
  }

  function testPause() public {
    stakingToken.pause();
    assertTrue(stakingToken.paused());
  }

  function testUnpause() public {
    stakingToken.pause();
    stakingToken.unpause();
    assertFalse(stakingToken.paused());
  }

  function testFailMintTokenWhenPaused() public {
    stakingToken.pause();
    stakingToken.mint(address(this), 1000 * 10 ** 18);
  }

  function testFailTransferWhenPaused() public {
    stakingToken.mint(address(this), 1000 * 10 ** 18);
    stakingToken.pause();
    stakingToken.transfer(address(0x1), 100 * 10 ** 18);
  }

  function testTransfer() public {
    stakingToken.mint(address(this), 1000 * 10 ** 18);
    stakingToken.transfer(address(0x1), 100 * 10 ** 18);

    assertEq(stakingToken.balanceOf(address(this)), 900 * 10 ** 18);
    assertEq(stakingToken.balanceOf(address(0x1)), 100 * 10 ** 18);
  }
}
