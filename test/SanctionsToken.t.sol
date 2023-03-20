// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {SanctionsToken} from "../src/SanctionsToken.sol";

contract SanctionsTokenTest is Test {
  SanctionsToken token;

  function setUp() public {
    token = new SanctionsToken("Sanctions Token", "SAN");
  }

  /// @notice Test minting of tokens.
  function testMinting() public {
    uint256 initialSupply = token.totalSupply();
    token.mint(address(this), 1000);
    uint256 newSupply = token.totalSupply();
    assertEq(newSupply, initialSupply + 1000);
  }

  /// @notice Test transfer of tokens and sanctions functionality.
  function testSanctionedTransfer() public {
    token.mint(address(this), 1000);

    address addr1 = address(0x123);
    token.transfer(addr1, 500);
    uint256 addr1Balance = token.balanceOf(addr1);
    assertEq(addr1Balance, 500);

    token.banAddress(addr1);
    assertTrue(token.isBanned(addr1));

    vm.prank(addr1);
    token.approve(address(this), 300);

    vm.prank(address(this));
    try token.transferFrom(addr1, address(0x789), 100) {
      fail("should not allow transfer from banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "Sanctioned: Address cannot send the token");
    }

    token.unbanAddress(addr1);
    assertFalse(token.isBanned(addr1));

    token.transfer(address(0x456), 100);
    uint256 addr2Balance = token.balanceOf(address(0x456));
    assertEq(addr2Balance, 100);
  }

  function testTokenBurning() public {
    token.mint(address(this), 1000);

    uint256 initialSupply = token.totalSupply();
    token.burn(address(this), 500);

    uint256 newSupply = token.totalSupply();
    assertEq(newSupply, initialSupply - 500);
  }

  function testTokenBurningFromBannedAddress() public {
    token.mint(address(this), 1000);
    address addr1 = address(0x123);
    token.transfer(addr1, 500);

    token.banAddress(addr1);
    vm.prank(addr1);
    token.approve(address(this), 500);

    vm.prank(address(this));
    try token.burn(addr1, 100) {
      fail("should not allow burning from a banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "Sanctioned: Address cannot burn the token");
    }
  }

  function testSendingTokensToBannedAddress() public {
    token.mint(address(this), 1000);
    address addr1 = address(0x123);
    token.banAddress(addr1);

    try token.transfer(addr1, 100) {
      fail("should not allow sending tokens to a banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "Sanctioned: Address cannot receive the token");
    }
  }

  /// @notice Test `approve` and `transferFrom` when the recipient is a banned address.
  function testApproveAndTransferFromToBannedAddress() public {
    token.mint(address(this), 1000);

    address addr1 = address(0x123);
    token.banAddress(addr1);
    token.approve(address(this), 100);

    try token.transferFrom(address(this), addr1, 100) {
      fail("should not allow transfer to a banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "Sanctioned: Address cannot receive the token");
    }
  }

  /// @notice Test `banAddress` and `unbanAddress` functions can only be called by the owner.
  function testBanAndUnbanAddressRestrictions() public {
    address addr1 = address(0x123);
    address nonOwner = address(0x456);

    token.banAddress(addr1);

    vm.prank(nonOwner);
    try token.banAddress(addr1) {
      fail("should not allow non-owner to ban an address");
    } catch Error(string memory reason) {
      assertEq(reason, "Ownable: caller is not the owner");
    }

    vm.prank(address(this));
    token.unbanAddress(addr1);
    vm.prank(nonOwner);
    try token.unbanAddress(addr1) {
      fail("should not allow non-owner to unban an address");
    } catch Error(string memory reason) {
      assertEq(reason, "Ownable: caller is not the owner");
    }
  }
}
