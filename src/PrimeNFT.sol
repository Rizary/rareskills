// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PrimeNFT is ERC721Enumerable, Ownable {
  uint256 public constant MAX_SUPPLY = 20;

  constructor() ERC721("Prime NFT", "PNFT") {}

  function mintNFT(uint256 tokenId) external onlyOwner {
    require(tokenId > 0 && tokenId <= MAX_SUPPLY, "Invalid tokenId");
    _safeMint(msg.sender, tokenId);
  }
}
