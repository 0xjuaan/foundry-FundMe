//SPDX-License-Identifier: MIT
// We run this to quickly fund or withdraw from a contract that we deployed
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";
contract Fund is Script {

    uint256 constant SEND_VALUE = 0.01 ether;
    function fund(address recentAddress) public {
        vm.startBroadcast();
        FundMe(payable(recentAddress)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console.log("Funded it with %i", SEND_VALUE);
        
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fund(contractAddress);

    }
}

contract Withdraw is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function withdraw(address recentAddress) public {

        vm.startBroadcast();
        FundMe(payable(recentAddress)).withdraw();
        vm.stopBroadcast();
        console.log("Funded it with %i", SEND_VALUE);
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdraw(contractAddress);

    }
}