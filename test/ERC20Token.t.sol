// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../src/ERC20Token.sol";

contract ERC20TokenTest is Test {
    ERC20Token myERC20Token;
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
    }

    function testGetTokenName() public {
        string memory tokenName = myERC20Token.name();
        assertEq(tokenName, mockTokenName);
    }

    function testGetTokenSymbol() public {
        string memory tokenSymbol = myERC20Token.symbol();
        assertEq(tokenSymbol, mockTokenSymbol);
    }

    function testGetDecimalsVariable() public {
        assertEq(myERC20Token.decimals(), 18);
    }

    function testGetCurrentSupply() public {
        assertEq(
            myERC20Token.totalSupply(),
            initialSupply * (10**myERC20Token.decimals())
        );
    }

    function testGetMaxSupply() public {
        assertEq(myERC20Token.cap(), maxSupply * (10**myERC20Token.decimals()));
    }

    function testGetBalanceOf() public {
        assertEq(
            myERC20Token.balanceOf(testMaster),
            initialSupply * (10**myERC20Token.decimals())
        );
    }

    function testTransfer() public {
        myERC20Token.transfer(user0x2, testAmount);
        assertEq(myERC20Token.balanceOf(user0x2), testAmount);
    }

    function testMint() public {
        myERC20Token.mint(user0x3, testAmount);
        assertEq(myERC20Token.balanceOf(user0x3), testAmount);
    }

    function testOnlyAccessControlRoleCanMint() public {
        vm.startPrank(user0x3);
        vm.expectRevert(
            "ERC20PresetMinterPauser: must have minter role to mint"
        );
        myERC20Token.mint(user0x3, testAmount);
        vm.stopPrank();
    }

    function testTransferFromFailsNoAllowance() public {
        myERC20Token.mint(user0x2, testAmount);
        vm.expectRevert("ERC20: insufficient allowance");
        myERC20Token.transferFrom(user0x2, user0x3, testAmount);
    }

    function testApprove() public {
        uint256 approvedAllowance = 15 * (10**18);
        myERC20Token.mint(user0x2, testAmount);
        vm.startPrank(user0x2);
        myERC20Token.approve(testMaster, approvedAllowance);
        vm.stopPrank();
        myERC20Token.transferFrom(user0x2, user0x3, approvedAllowance);
        assertEq(myERC20Token.balanceOf(user0x3), approvedAllowance);
    }

    function testGetAllowance() public {
        uint256 approvedAllowance = 15 * (10**18);
        myERC20Token.mint(user0x2, testAmount);
        vm.startPrank(user0x2);
        myERC20Token.approve(testMaster, approvedAllowance);
        vm.stopPrank();
        assertEq(
            myERC20Token.allowance(user0x2, testMaster),
            approvedAllowance
        );
    }

    function testIncreaseAllowance() public {
        uint256 approvedAllowance = 15 * (10**18);
        myERC20Token.mint(user0x2, testAmount);
        vm.startPrank(user0x2);
        myERC20Token.approve(testMaster, approvedAllowance);
        myERC20Token.increaseAllowance(testMaster, 10 * (10**18));
        vm.stopPrank();
        assertEq(myERC20Token.allowance(user0x2, testMaster), testAmount);
    }

    function testDecreaseAllowance() public {
        uint256 approvedAllowance = 15 * (10**18);
        myERC20Token.mint(user0x2, testAmount);
        vm.startPrank(user0x2);
        myERC20Token.approve(testMaster, approvedAllowance);
        myERC20Token.decreaseAllowance(testMaster, 10 * (10**18));
        vm.stopPrank();
        assertEq(myERC20Token.allowance(user0x2, testMaster), 5 * (10**18));
    }

    function testTransferFrom() public {
        uint256 approvedAllowance = 15 * (10**18);
        myERC20Token.mint(user0x2, testAmount);
        vm.startPrank(user0x2);
        myERC20Token.approve(testMaster, approvedAllowance);
        myERC20Token.increaseAllowance(testMaster, 10 * (10**18));
        vm.stopPrank();
        myERC20Token.transferFrom(user0x2, user0x3, testAmount);
        assertEq(myERC20Token.balanceOf(user0x3), testAmount);
    }

    function testOnlyOwnerCanSetMinterRole() public {
        vm.startPrank(user0x2);
        vm.expectRevert(
            "ERC20Token: Only the contract owner can call this function"
        );
        myERC20Token.setMinterRole(user0x2);
        vm.stopPrank();
    }

    function testSetMinterRole() public {
        myERC20Token.setMinterRole(user0x2);
        vm.startPrank(user0x2);
        myERC20Token.mint(user0x3, testAmount);
        vm.stopPrank();
        assertEq(myERC20Token.balanceOf(user0x3), testAmount);
    }

    function testGetRoleMember() public {
        bytes32 minterRole = keccak256("MINTER_ROLE");
        myERC20Token.setMinterRole(user0x2);
        assertEq(myERC20Token.getRoleMember(minterRole, 1), user0x2);
    }
}
