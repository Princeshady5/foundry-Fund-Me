// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    MockV3Aggregator mockV3Aggregator;
    address USER = makeAddr("USER");

    receive() external payable {}

    // Constants for mock constructor
    uint8 public constant DECIMALS = 8;
    uint256 public constant INITIAL_ANSWER = 2000e8;
    unit265 constant GAs_Price = 1e9; // 1 Gwei

    function setUp() public {
        mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        fundMe = new FundMe(address(mockV3Aggregator));
        vm.deal(USER, 10e18); // Give USER 10 ETH for testing
    }

    function testMinVariable() public {
        assertEq(
            fundMe.MINIMUM_USD(),
            5e18,
            "The minimum USD value should be 5e18"
        );
    }

    function testOwnerIsMessageSender() public {
        assertEq(fundMe.i_owner(), address(this), "Owner should be msg.sender");
        console.log("Owner:", fundMe.i_owner());
        console.log("msg.sender:", msg.sender);
    }

    function testFundMeDeployment() public {
        assertTrue(address(fundMe) != address(0), "FundMe should be deployed");
        console.log("FundMe deployed at:", address(fundMe));
    }

    function testPriceFeedVersionIsCorrect() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4, "Mock version should be 4");
        console.log("Price feed version:", version);
    }

    function testFundFailsWithoutEnoughEth() public {
        uint256 sendValue = 1e15; // 0.001 ETH, likely less than $5
        vm.expectRevert();
        fundMe.fund{value: sendValue}();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        uint256 sendValue = 6e18;
        fundMe.fund{value: sendValue}();

        assertEq(
            fundMe.s_addressToAmountFunded(USER),
            sendValue,
            "Amount funded should match sent value"
        );
        assertEq(fundMe.s_funders(0), USER, "Funder should be recorded");
    }

    function testAddsFundersToArraysOfFunders() public {
        vm.prank(USER);
        uint256 sendValue = 6e18;
        fundMe.fund{value: sendValue}(); // Call fund from USER with enough ETH

        address funder = fundMe.getFunder(0); // fundMe not fundme
        assertEq(funder, USER, "Funder should be USER"); // funder not Funder
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        uint256 sendValue = 6e18;
        fundMe.fund{value: sendValue}();

        vm.expectRevert();
        vm.prank(USER);

        fundMe.withdraw(); // USER tries to withdraw, should fail
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 6e18}();
        _;
    }

    function testWithdrawWithASingleFunder() public funded {
        address owner = fundMe.getOwner();
        uint256 initialBalance = owner.balance;
        uint256 funderBalance = address(fundMe).balance;

        vm.txGasPrice(Gas_Price); // Set gas price to 1 Gwei
        unit256 gasStart = gasleft(); // Start gas price
        vm.prank(owner); // Ensure the right sender
        fundMe.withdraw();
        unit256 gasEnd = gasleft(); // End gas price

        uint256 endingOwnerBalance = owner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, initialBalance + funderBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 sendValue = 6e18;
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), sendValue);
            fundMe.fund{value: sendValue}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assertEq(
            address(fundMe).balance,
            0,
            "FundMe balance should be zero after withdrawal"
        );
        assertEq(
            fundMe.getOwner().balance,
            startingFundMeBalance + startingOwnerBalance,
            "Owner's balance should equal starting balance plus FundMe balance"
        );
    }
}
