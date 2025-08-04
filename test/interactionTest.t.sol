// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;
    address USER = makeAddr("USER");

    // Constants for the mock
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;

    function setUp() public {
        // Deploy the mock price feed
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_ANSWER
        );

        // Deploy FundMe with mock feed
        fundMe = new FundMe(address(mockV3Aggregator));

        // Give USER some ETH to fund with
        vm.deal(USER, 10e18);
    }

    function testUserCanFund() public {
        vm.prank(USER); // USER will be the sender
        fundMe.fund{value: 5e18}(); // Should be more than $5

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER, "The first funder should be USER");

        uint256 amount = fundMe.getAddressToAmountFunded(USER);
        assertEq(amount, 5e18, "Funding amount should be recorded correctly");
    }
}
