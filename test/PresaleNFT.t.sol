// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {PresaleNFT} from "../src/PresaleNFT.sol";
import {Merkle} from "@murky/src/Merkle.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract PresaleNFTTest is Test {
  PresaleNFT nft;
  Merkle merkle;
  address[] private addresses =
    [address(0x123), address(0x234), address(0x456), address(0x567), address(0x678)];
  address addr6 = address(0x789);
  bytes32 private merkleRootTest;
  bytes32[] public data = new bytes32[](5);

  function setUp() public {
    nft = new PresaleNFT();
    merkle = new Merkle();
    for (uint256 i = 0; i < addresses.length; i++) {
      data[i] = bytes32(bytes20(addresses[i]));
    }
    nft._addToPresaleList(addresses[0], 3, uint256(uint160(addresses[0]))); // 3 NFT
    nft._addToPresaleList(addresses[1], 2, uint256(uint160(addresses[1]))); // 2 NFT
    nft._addToPresaleList(addresses[2], 1, uint256(uint160(addresses[2]))); // 1 NFT
    nft._addToPresaleList(addresses[3], 3, uint256(uint160(addresses[3]))); // 3 NFT
    nft._addToPresaleList(addresses[4], 1, uint256(uint160(addresses[4]))); // 1 NFT

    merkleRootTest = merkle.getRoot(data);
    nft.setMerkleRoot(merkleRootTest);
  }

  function testPublicMint() public {
    uint256 initialSupply = nft.totalSupply();
    uint256 tokenPrice = nft.PRICE();

    vm.prank(addr6, addr6);
    vm.deal(addr6, tokenPrice);
    nft.publicMint{value: tokenPrice}();

    uint256 newSupply = nft.totalSupply();
    assertEq(newSupply, initialSupply + 1);
  }

  function testFailPublicMintBot() public {
    uint256 initialSupply = nft.totalSupply();
    uint256 tokenPrice = nft.PRICE();

    vm.prank(addresses[0], addresses[0]);
    vm.deal(addresses[0], tokenPrice);
    nft.publicMint{value: tokenPrice}();
    vm.expectRevert();
  }

  function testPublicMintWrongPrice() public {
    uint256 tokenPrice = nft.DISCOUNTED_PRICE();

    vm.prank(addresses[0], addresses[0]);
    vm.deal(addresses[0], tokenPrice);
    try nft.publicMint{value: tokenPrice}() {
      fail("public mint should failed");
    } catch Error(string memory reason) {
      assertEq(reason, "wrong price");
    }
  }

  function testPresaleMint() public {
    uint256 amount = 1;
    uint256 index = uint256(uint160(addresses[2]));
    bytes32[] memory proof = merkle.getProof(data, 2);

    uint256 initialSupply = nft.totalSupply();
    uint256 discountedPrice = nft.DISCOUNTED_PRICE();

    vm.prank(addresses[2], addresses[2]);
    vm.deal(addresses[2], discountedPrice);
    nft.presale{value: discountedPrice}(amount, index, proof);

    uint256 newSupply = nft.totalSupply();
    assertEq(newSupply, initialSupply + 1);
  }

  function testPresaleMintBot() public {
    address validAddress = addresses[0];
    uint256 amount = 3;
    uint256 index = uint256(uint160(validAddress));
    bytes32[] memory proof = merkle.getProof(data, 1);

    uint256 discountedPrice = nft.DISCOUNTED_PRICE();

    vm.prank(address(this), validAddress);
    vm.deal(address(nft), discountedPrice);
    try nft.presale{value: discountedPrice}(amount, index, proof) {
      fail("presale mint should failed");
    } catch Error(string memory reason) {
      assertEq(reason, "bot is not allowed");
    }
  }

  function testPresaleMintWrongPrice() public {
    address validAddress = addresses[3];
    uint256 amount = 3;
    uint256 index = uint256(uint160(validAddress));
    bytes32[] memory proof = merkle.getProof(data, 4);

    uint256 normalPrice = nft.PRICE();

    vm.prank(validAddress, validAddress);
    vm.deal(validAddress, normalPrice);

    try nft.presale{value: normalPrice}(amount, index, proof) {
      fail("public mint should failed");
    } catch Error(string memory reason) {
      assertEq(reason, "wrong price");
    }
  }

  function _verifyProof(
    address _who,
    bytes32[] memory _merkleProof,
    bytes32 merkleRoot
  ) internal view returns (bool) {
    bytes32 node = bytes32(bytes20(_who));
    return MerkleProof.verify(_merkleProof, merkleRoot, node);
  }

  function testVerifyProof() public {
    address validAddress = addresses[3];
    bytes32[] memory proof = merkle.getProof(data, 3);

    bool proofIsValid = _verifyProof(validAddress, proof, merkleRootTest);

    assertEq(true, proofIsValid);
  }

  function testVerifyWrongProof() public {
    address invalidAddress = address(0x2);
    bytes32[] memory proof = merkle.getProof(data, 1);

    bool proofIsValid = _verifyProof(invalidAddress, proof, merkleRootTest);

    assertEq(false, proofIsValid);
  }
}
