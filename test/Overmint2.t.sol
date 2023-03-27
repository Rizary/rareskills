// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {Overmint2Attacker} from "../src/Overmint2Attacker.sol";
import {Overmint2} from "../src/Overmint2.sol";

contract Overmint2Test is Test {
  Overmint2 overmint2;
  Overmint2Attacker overmint2Attacker;
  uint256 private tokenPrice;
  address attackerWallet = address(0x123);
  address overmint2Addr;

  function setUp() public {
    overmint2 = new Overmint2();
    vm.prank(attackerWallet);
    overmint2Attacker = new Overmint2Attacker(address(overmint2));
    overmint2Addr = address(overmint2Attacker);
  }

  function testMintAttack() public {
    vm.startPrank(attackerWallet, attackerWallet);
    overmint2Attacker.attack();
    vm.stopPrank();

    assertEq(5, overmint2.balanceOf(attackerWallet));
  }
}
