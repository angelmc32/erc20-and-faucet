// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../src/ERC20Token.sol";
import "../src/Faucet.sol";

contract ERC20TokenTest is Test {
    ERC20Token public myERC20Token;
    Faucet public myFaucet;
    uint256 withdrawalAmount = 25 * (10**18);
    address testMaster = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
    address contractOwner = address(0x1);
    address user0x2 = address(0x2);
    address user0x3 = address(0x3);
    string mockTokenName = "MockToken";
    string mockTokenSymbol = "MOCK";
    uint256 maxSupply = 100;
    uint256 initialSupply = 50;
    uint256 testAmount = 25 * (10**18);

    function setUp() public {
        myERC20Token = new ERC20Token(
            mockTokenName,
            mockTokenSymbol,
            testMaster,
            maxSupply,
            initialSupply
        );
        emit log_named_uint("Total supply", myERC20Token.totalSupply());
        myFaucet = new Faucet(address(myERC20Token), withdrawalAmount);
        myERC20Token.setMinterRole(address(myFaucet));
    }

    function testARequestTokensTriggersMint() public {
        vm.startPrank(user0x2);
        myFaucet.requestTokens();
        vm.stopPrank();
        uint256 currentSupply = (initialSupply * (10**18)) + withdrawalAmount;
        assertEq(myERC20Token.totalSupply(), currentSupply);
    }

    function testRequestTokens() public {
        vm.startPrank(user0x2);
        myFaucet.requestTokens();
        vm.stopPrank();
        assertEq(myERC20Token.balanceOf(user0x2), withdrawalAmount);
    }

    function testFailRequestTokensTimelock() public {
        vm.startPrank(user0x2);
        myFaucet.requestTokens();
        myFaucet.requestTokens();
        vm.stopPrank();
        assertEq(myERC20Token.balanceOf(user0x2), withdrawalAmount);
    }
}
