/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from
  "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title PresaleNFT
/// @notice This NFT contract has presale feature using merkle tree and bitmap
contract PresaleNFT is ERC165, ERC721, Ownable, ERC2981 {
  using BitMaps for BitMaps.BitMap;

  uint256 public immutable PRICE;
  uint256 public immutable DISCOUNTED_PRICE;
  uint256 public totalSupply;

  address private _owner;
  address private _pendingOwner;

  mapping(address => uint256) private _publicMintedCount;
  mapping(address => uint256) private _presaleMintedCount;
  mapping(address => uint256) private _presaleAmount;
  mapping(uint256 => address) private _owners;

  bytes32 private merkleRoot;

  BitMaps.BitMap private bitmap;

  event OwnershipTransferInitiated(address indexed previousOwner, address indexed newOwner);
  event OwnershipTransferCompleted(address indexed previousOwner, address indexed newOwner);

  constructor() ERC721("Presale NFT", "PNFT") {
    PRICE = 0.07 ether;
    DISCOUNTED_PRICE = 0.045 ether;
    totalSupply = 1;
    _owner = msg.sender;
    _setDefaultRoyalty(msg.sender, 250);
  }

  /// @notice Set the new merkle root
  /// @param merkleRoot_ new merkle root
  function setMerkleRoot(bytes32 merkleRoot_) external {
    merkleRoot = merkleRoot_;
  }

  /// @notice Minting the NFT publicly
  /// @dev Explain to a developer any extra details
  function publicMint() external payable {
    require(msg.sender == tx.origin, "bot is not allowed");
    uint256 _totalSupply = totalSupply;
    uint256 _totalMinted = _publicMintedCount[msg.sender];
    require(_totalSupply < 11, "supply exceeded");
    require(_totalMinted < 2, "limit reached");
    require(msg.value == PRICE, "wrong price");

    unchecked {
      _publicMintedCount[msg.sender]++;
    }
    _owners[_totalSupply] = msg.sender;
    emit Transfer(address(0), msg.sender, _totalSupply);

    unchecked {
      _totalSupply++;
    }
    totalSupply = _totalSupply;
  }

  /// @notice Minting that available only for address listed in presale
  /// @dev We use merkle root to verify the minter and bitmap to track minted amount
  /// @param _amount token to be minted
  /// @param _index address stored in the bitmap
  /// @param _merkleProof generated from the client side
  function presale(
    uint256 _amount,
    uint256 _index,
    bytes32[] calldata _merkleProof
  ) external payable {
    require(msg.sender == tx.origin, "bot is not allowed");
    require(msg.value == DISCOUNTED_PRICE, "wrong price");
    require(_verifyProof(msg.sender, _merkleProof), "address is not recognized");
    require(bitmap.get(_index), "address cannot minted presale");

    uint256 _totalSupply = totalSupply;

    unchecked {
      _presaleMintedCount[msg.sender]++;
    }
    _owners[_totalSupply] = msg.sender;
    emit Transfer(address(0), msg.sender, _totalSupply);

    unchecked {
      _totalSupply++;
    }
    totalSupply = _totalSupply;
    if (_presaleMintedCount[msg.sender] == _presaleAmount[msg.sender]) {
      bitmap.unset(_index);
    }
  }

  /// @notice Adding address and amount for presale
  /// @dev Assuming the amount is dynamic, we store it using mapping
  /// @param _who address granted with presale
  /// @param _amount max amount granted
  /// @param _index index of the address
  function _addToPresaleList(address _who, uint256 _amount, uint256 _index) external onlyOwner {
    require(_amount < 11, "cannot set to max supply");
    require(uint256(uint160(_who)) == _index, "invalid index for the address");
    bitmap.set(_index);
    _presaleAmount[msg.sender] = _amount;
  }

  /// @notice Verify claim to the Merkle Tree
  /// @dev Explain to a developer any extra details
  /// @param _who address to be verified
  /// @param _merkleProof proof generated
  /// @return bool return true if it exists in merkle tree and false if otherwise

  function _verifyProof(
    address _who,
    bytes32[] memory _merkleProof
  ) internal view returns (bool) {
    bytes32 node = bytes32(bytes20(_who));
    return MerkleProof.verify(_merkleProof, merkleRoot, node);
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721, ERC2981, ERC165)
    returns (bool)
  {
    return interfaceId == type(IERC721).interfaceId
      || interfaceId == type(IERC721Metadata).interfaceId
      || interfaceId == type(ERC2981).interfaceId || interfaceId == type(ERC165).interfaceId
      || super.supportsInterface(interfaceId);
  }

  function renounceOwnership() public pure override {
    require(false, "cannot renounce");
  }

  /// @notice Returns the address of the current owner.
  /// @return The address of the current owner.
  function owner() public view override returns (address) {
    return _owner;
  }

  /// @notice Returns the address of the pending owner.
  /// @return The address of the pending owner.
  function pendingOwner() public view returns (address) {
    return _pendingOwner;
  }

  /// @notice Initiates a transfer of ownership to a new address.
  /// @param newOwner The address of the new owner.
  function transferOwnership(address newOwner) public override onlyOwner {
    require(newOwner != address(0), "SecureOwnable: new owner is the zero address");
    require(newOwner != _owner, "SecureOwnable: new owner is already the current owner");
    _pendingOwner = newOwner;
    emit OwnershipTransferInitiated(_owner, _pendingOwner);
  }

  /// @notice Accepts the ownership transfer initiated by the current owner.
  function acceptOwnership() public {
    require(msg.sender == _pendingOwner, "SecureOwnable: caller is not the pending owner");
    _owner = _pendingOwner;
    delete _pendingOwner;
    super._transferOwnership(_owner);
    emit OwnershipTransferCompleted(_owner, _pendingOwner);
  }
}
