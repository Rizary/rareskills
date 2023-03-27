// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {Overmint1Attacker} from "../src/Overmint1Attacker.sol";
import {Overmint1} from "../src/Overmint1.sol";

contract Overmint1Test is Test {
  Overmint1 overmint1;
  Overmint1Attacker overmint1Attacker;
  uint256 private tokenPrice;
  address attackerWallet = address(0x123);

  function setUp() public {
    overmint1 = new Overmint1();
    vm.prank(attackerWallet);
    overmint1Attacker = new Overmint1Attacker(address(overmint1));
  }

  function testMintAttack() public {
    vm.startPrank(attackerWallet, attackerWallet);
    for (uint256 i = 1; i < 3; i++) {
      overmint1Attacker.attack();
      overmint1.mint();
    }
    overmint1Attacker.attack();
    vm.stopPrank();

    assertEq(5, overmint1.balanceOf(attackerWallet));
  }
}
