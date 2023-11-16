// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {Fund, Withdraw} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {

    address USER = makeAddr("user");
    uint256 SEND_VALUE = 1e17;
    uint256 GAS_PRICE = 1e18;
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }

    function testFundable() public {
        Fund fundScript = new Fund();
        fundScript.fund(address(fundMe));

        Withdraw withdraw = new Withdraw();
        withdraw.withdraw(address(fundMe));

        
        assertEq(address(fundMe).balance , 0);
    }
}