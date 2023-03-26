// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./PrimeNFT.sol";

contract PrimeChecker {
  PrimeNFT public nft;

  constructor(address nftAddress) {
    nft = PrimeNFT(nftAddress);
  }

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

  function countPrimeTokens(address owner) external view returns (uint256) {
    uint256 balance = nft.balanceOf(owner);
    uint256 primeCount = 0;

    for (uint256 i = 0; i < balance; i++) {
      uint256 tokenId = nft.tokenOfOwnerByIndex(owner, i);
      if (isPrime(tokenId)) {
        primeCount++;
      }
    }
    return primeCount;
  }
}
