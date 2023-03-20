// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {GodModeToken} from "../src/GodModeToken.sol";

/// @title GodModeTokenTest
/// @notice A test suite for the GodModeToken contract.
contract GodModeTokenTest is Test {
  GodModeToken token;

  function setUp() public {
    token = new GodModeToken("God Mode Token", "GOD", 60);
  }

  /// @notice Test minting of tokens.
  function testMinting() public {
    uint256 initialSupply = token.totalSupply();
    token.mint(address(this), 1000);
    uint256 newSupply = token.totalSupply();
    assertEq(newSupply, initialSupply + 1000);
  }

  /// @notice Test adding and removing god addresses.
  function testAddRemoveGod() public {
    token.mint(address(0x123), 1000);
    token.addGod(address(0x123));
    assertTrue(token.isGod(address(0x123)));

    token.removeGod(address(0x123));
    assertFalse(token.isGod(address(0x123)));
  }

  /// @notice Test godTransfer and godTransferDelay.
  function testGodTransferAndDelay() public {
    token.mint(address(0x123), 1000);
    token.addGod(address(this));

    token.godTransfer(address(0x123), address(0x456), 500);
    uint256 addr1Balance = token.balanceOf(address(0x123));
    uint256 addr2Balance = token.balanceOf(address(0x456));
    assertEq(addr1Balance, 500);
    assertEq(addr2Balance, 500);

    // Test godTransfer delay
    try token.godTransfer(address(0x123), address(0x456), 100) {
      fail("should not allow godTransfer before delay");
    } catch Error(string memory reason) {
      assertEq(reason, "GodModeToken: Transfer delay not yet passed");
    }
  }

  /// @notice Test godTransfer with a non-god address.
  function testGodTransferNonGod() public {
    token.mint(address(0x123), 1000);

    try token.godTransfer(address(0x123), address(0x456), 500) {
      assertTrue(false, "should not allow non-god address to execute godTransfer");
    } catch Error(string memory reason) {
      assertEq(reason, "GodModeToken: Caller is not a god address");
    }
  }
}
