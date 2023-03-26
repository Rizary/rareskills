// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/PrimeNFT.sol";
import "../src/PrimeChecker.sol";

contract PrimeNFTTest is Test {
  PrimeNFT nft;
  PrimeChecker primeChecker;
  address addr1 = address(0x123);

  /// @notice copy over the function just for testing
  function isPrime(uint256 number) private pure returns (bool) {
    if (number < 2) {
      return false;
    }
    for (uint256 i = 2; i * i <= number; i++) {
      if (number % i == 0) {
        return false;
      }
    }
    return true;
  }

  function setUp() public {
    vm.startPrank(addr1, addr1);
    nft = new PrimeNFT();
    primeChecker = new PrimeChecker(address(nft));
    vm.stopPrank();
  }

  function testMintNFT() public {
    vm.startPrank(addr1, addr1);
    nft.mintNFT(1);
    assertEq(nft.ownerOf(1), addr1);
    nft.mintNFT(20);
    assertEq(nft.ownerOf(20), addr1);
    vm.stopPrank();
  }

  function testMintNFTInvalidTokenId() public {
    vm.prank(addr1, addr1);
    try nft.mintNFT(21) {
      fail("mint should failed");
    } catch Error(string memory reason) {
      assertEq(reason, "Invalid tokenId");
    }
  }

  function testIsPrime() public {
    assertTrue(isPrime(2));
    assertTrue(isPrime(3));
    assertTrue(isPrime(5));
    assertTrue(isPrime(7));
    assertTrue(isPrime(11));
    assertTrue(isPrime(13));
    assertTrue(isPrime(17));
    assertTrue(isPrime(19));

    assertFalse(isPrime(1));
    assertFalse(isPrime(4));
    assertFalse(isPrime(6));
    assertFalse(isPrime(8));
    assertFalse(isPrime(9));
    assertFalse(isPrime(10));
    assertFalse(isPrime(12));
    assertFalse(isPrime(14));
    assertFalse(isPrime(15));
    assertFalse(isPrime(16));
    assertFalse(isPrime(18));
    assertFalse(isPrime(20));
  }

  function testCountPrimeTokens() public {
    vm.startPrank(addr1, addr1);
    for (uint256 i = 1; i <= 20; i++) {
      nft.mintNFT(i);
    }

    assertEq(primeChecker.countPrimeTokens(addr1), 8);
    vm.stopPrank();
  }
}
