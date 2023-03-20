// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {BondingCurveToken} from "../src/BondingCurveToken.sol";

contract BondingCurveTokenTest is Test {
  BondingCurveToken private _token;

  constructor() payable {}
  receive() external payable {}

  event TestContractBalance(uint256 b, uint256 a);

  function setUp() public {
    _token = new BondingCurveToken("BondingCurveToken", "BCT");
    _token.mint(address(this), 20 * 1 ether);
  }

  function testBuy() public {
    uint256 initialBalance = address(this).balance;
    uint256 value = 1 ether;

    _token.buy{value: value}();

    uint256 expectedBalance = initialBalance - value;
    assert(address(this).balance == expectedBalance);
    assert(_token.balanceOf(address(this)) > 0);
  }

  function testSell() public {
    uint256 value = 1 ether;
    _token.buy{value: value}();

    uint256 initialBalance = address(this).balance;
    uint256 tokenAmount = _token.balanceOf(address(this));

    _token.sell(tokenAmount);

    uint256 expectedBalance =
      initialBalance + _token.calculateEtherAmountToReceive(0, tokenAmount);
    assert(address(this).balance == expectedBalance);
    assert(_token.balanceOf(address(this)) == 0);
  }

  function testBuyWithAdditionalData() public {
    uint256 initialBalance = address(this).balance;
    uint256 value = 1 ether;

    // The test contract should have enough Ether balance before running this test
    if (address(this).balance < value) {
      payable(address(this)).transfer(value);
    }

    // Send Ether directly to the contract
    (bool success,) = address(_token).call{value: value}("");
    assert(success);

    uint256 expectedBalance = initialBalance - value;
    emit TestContractBalance(initialBalance, address(this).balance);
    assert(address(this).balance == expectedBalance);
    assert(_token.balanceOf(address(this)) > 0);
  }

  function testSellWithAdditionalData() public {
    uint256 value = 1 ether;
    _token.buy{value: value}();

    uint256 initialBalance = address(this).balance;
    uint256 tokenAmount = _token.balanceOf(address(this));

    bytes memory data = abi.encode(tokenAmount);
    _token.transferAndCall(address(_token), tokenAmount, data);

    uint256 expectedBalance =
      initialBalance + _token.calculateEtherAmountToReceive(0, tokenAmount);
    assert(address(this).balance == expectedBalance);
    assert(_token.balanceOf(address(this)) == 0);
  }

  function testFailBuyWithInsufficientEther() public {
    try _token.buy{value: 0}() {
      // If the buy function call does not revert, the test fails
      assert(false);
    } catch Error(string memory reason) {
      // If the buy function call reverts, the test is successful
      assert(true);
    }
  }

  function testFailSellWithInsufficientTokens() public {
    uint256 tokenAmount = 1 ether;
    _token.sell(tokenAmount);
  }
}
