// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {PresaleNFT} from "../src/PresaleNFT.sol";

contract PresaleNFTTest is Test {
  PresaleNFT nft;
  Merkle merkle;

  function beforeEach() public {
    nft = new PresaleNFT(address(this));
    merkle = new Merkle();
    nft.setMerkleRoot(merkle.getRoot());
  }

  function testPublicMint() public {
    uint256 initialSupply = nft.totalSupply();
    uint256 tokenPrice = nft.PRICE();

    payable(address(nft)).transfer(tokenPrice);

    nft.publicMint{value: tokenPrice}();

    uint256 newSupply = nft.totalSupply();
    assertEq(newSupply, initialSupply + 1);
  }

  function testFailPublicMintBot() public {
    uint256 initialSupply = nft.totalSupply();
    uint256 tokenPrice = nft.PRICE();

    payable(address(nft)).transfer(tokenPrice);

    address(nft).call{value: tokenPrice}(abi.encodeWithSignature("publicMint()"));
  }

  function testFailPublicMintWrongPrice() public {
    uint256 tokenPrice = nft.PRICE();

    payable(address(nft)).transfer(tokenPrice);

    nft.publicMint{value: tokenPrice / 2}();
  }

  function testPresaleMint() public {
    address validAddress = address(0x1);
    uint256 amount = 5;
    uint256 index = uint256(uint160(validAddress));

    nft._addToPresaleList(validAddress, amount, index);

    bytes32[] memory proof = merkle.getProof(validAddress);

    uint256 initialSupply = nft.totalSupply();
    uint256 discountedPrice = nft.DISCOUNTED_PRICE();

    payable(address(nft)).transfer(discountedPrice);

    nft.presale(amount, index, proof){value: discountedPrice}();

    uint256 newSupply = nft.totalSupply();
    assertEq(newSupply, initialSupply + 1);
  }

  function testFailPresaleMintBot() public {
    address validAddress = address(0x1);
    uint256 amount = 5;
    uint256 index = uint256(uint160(validAddress));

    nft._addToPresaleList(validAddress, amount, index);

    bytes32[] memory proof = merkle.getProof(validAddress);

    uint256 discountedPrice = nft.DISCOUNTED_PRICE();

    payable(address(nft)).transfer(discountedPrice);

    address(nft).call{value: discountedPrice}(
      abi.encodeWithSignature("presale(uint256,uint256,bytes32[])", amount, index, proof)
    );
  }

  function testFailPresaleMintWrongPrice() public {
    address validAddress = address(0x1);
    uint256 amount = 5;
    uint256 index = uint256(uint160(validAddress));

    nft._addToPresaleList(validAddress, amount, index);

    bytes32[] memory proof = merkle.getProof(validAddress);

    uint256 discountedPrice = nft.DISCOUNTED_PRICE();

    payable(address(nft)).transfer(discountedPrice);

    nft.presale(amount, index, proof){value: discountedPrice / 2}();
  }

  function testVerifyProof() public {
    address validAddress = address(0x1);
    uint256 amount = 5;
    uint256 index = uint256(uint160(validAddress));

    nft._addToPresaleList(validAddress, amount, index);

    bytes32[] memory proof = merkle.getProof(validAddress);

    bool proofIsValid = nft._verifyProof(validAddress, proof);

    assertTrue(proofIsValid);
  }

  function testFailVerifyProof() public {
    address invalidAddress = address(0x2);
    bytes32[] memory proof = merkle.getProof(invalidAddress);

    bool proofIsValid = nft._verifyProof(invalidAddress, proof);

    assertFalse(proofIsValid);
  }
}
