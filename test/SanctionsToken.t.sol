// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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

    try token.transfer(address(0x456), 100) {
      assertTrue(false, "should not allow transfer from banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "SanctionedToken: Banned addresses cannot send or receive tokens");
    }

    try token.transferFrom(addr1, address(0x789), 100) {
      assertTrue(false, "should not allow transfer from banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "SanctionedToken: Banned addresses cannot send or receive tokens");
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
    token.burn(500);

    uint256 newSupply = token.totalSupply();
    assertEq(newSupply, initialSupply - 500);
  }

  function testTokenBurningFromBannedAddress() public {
    token.mint(address(this), 1000);
    address addr1 = address(0x123);
    token.transfer(addr1, 500);

    token.banAddress(addr1);
    token.approve(addr1, 500);

    try token.burnFrom(addr1, 100) {
      fail("should not allow burning from a banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "SanctionedToken: Banned addresses cannot send or receive tokens");
    }
  }

  function testTokenBurningFromBannedAddress() public {
    token.mint(address(this), 1000);
    address addr1 = address(0x123);
    token.transfer(addr1, 500);

    token.banAddress(addr1);
    token.approve(addr1, 500);

    try token.burnFrom(addr1, 100) {
      fail("should not allow burning from a banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "SanctionedToken: Banned addresses cannot send or receive tokens");
    }
  }

  function testTokenBurningFromBannedAddress() public {
    token.mint(address(this), 1000);
    address addr1 = address(0x123);
    token.transfer(addr1, 500);

    token.banAddress(addr1);
    token.approve(addr1, 500);

    try token.burnFrom(addr1, 100) {
      fail("should not allow burning from a banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "SanctionedToken: Banned addresses cannot send or receive tokens");
    }
  }

  function testTokenBurningFromBannedAddress() public {
    token.mint(address(this), 1000);
    address addr1 = address(0x123);
    token.transfer(addr1, 500);

    token.banAddress(addr1);
    token.approve(addr1, 500);

    try token.burnFrom(addr1, 100) {
      fail("should not allow burning from a banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "SanctionedToken: Banned addresses cannot send or receive tokens");
    }
  }

  function testTokenBurningFromBannedAddress() public {
    token.mint(address(this), 1000);
    address addr1 = address(0x123);
    token.transfer(addr1, 500);

    token.banAddress(addr1);
    token.approve(addr1, 500);

    try token.burnFrom(addr1, 100) {
      fail("should not allow burning from a banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "SanctionedToken: Banned addresses cannot send or receive tokens");
    }
  }

  function testTokenBurningFromBannedAddress() public {
    token.mint(address(this), 1000);
    address addr1 = address(0x123);
    token.transfer(addr1, 500);

    token.banAddress(addr1);
    token.approve(addr1, 500);

    try token.burnFrom(addr1, 100) {
      fail("should not allow burning from a banned address");
    } catch Error(string memory reason) {
      assertEq(reason, "SanctionedToken: Banned addresses cannot send or receive tokens");
    }
  }
}
