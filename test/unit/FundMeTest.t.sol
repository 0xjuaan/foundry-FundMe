// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {

    address USER = makeAddr("user");
    uint256 SEND_VALUE = 1e17;
    uint256 GAS_PRICE = 1e18;
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }

    function testMinimumDonation() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundUpdatesGetter() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 10e18);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwner() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18};

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();

    }

    modifier funded {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        _;
    }

    function testWithdraw() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();

        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = tx.gasprice * (gasStart - gasEnd);

        // Assert
        uint256 endingOwnerBalance = fundMe.i_owner().balance;
        uint256 endingContractBalance = address(fundMe).balance;

        assertEq(endingOwnerBalance, startingContractBalance + startingOwnerBalance);
        assertEq(endingContractBalance, 0);
    }

    function testWithdrawMultipleFunders() public {
        /// Arrange
        uint160 numFunders = 10;
        
        for (uint160 i = 1; i <= numFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.i_owner().balance;
        uint256 endingContractBalance = address(fundMe).balance;

        assertEq(endingOwnerBalance, startingContractBalance + startingOwnerBalance);
        assertEq(endingContractBalance, 0);
    }
}