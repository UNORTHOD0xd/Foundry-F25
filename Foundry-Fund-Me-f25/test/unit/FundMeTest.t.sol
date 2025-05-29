// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../scripts/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 5e18; // 5 ETH in wei
    uint256 constant STARTING_BALANCE = 10e18; // 10 ETH in wei

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); // Sepolia ETH/USD Price Feed Address
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // Give USER 10 ETH    
        // Alternatively, you can use the address of the deployed contract
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(),5e18);
    }

    function testOwnerIsMsgSender() public view{
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        // This is a test to check if the price feed version is accurate
        // We can use a mock or a real price feed address here
        // For simplicity, we will just check if the price feed address is not zero
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        // This test checks if the fund function fails when not enough ETH is sent
        vm.expectRevert("You need to spend more ETH!"); //"Hey, the next line should revert"
        fundMe.fund(); 
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // Send 5 ETH

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE, "The amount funded should be 5 ETH");
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // Send 5 ETH

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER, "The first funder should be USER");
    }

    modifier funded() {
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // Send 5 ETH
        _;
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); 
     
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        vm.prank(fundMe.getOwner()); // The next TX will be sent by the owner
        fundMe.withdraw();
        // Assert 
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0, "The FundMe contract balance should be 0 after withdrawal");
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance, "The owner's balance should be equal to the starting balance plus the FundMe contract balance");

    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; 
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // address ()
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}(); // Each address funds the contract with 5 ETH
            // fund the contract
        }

        //Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner()); // The next TX will be sent by the owner
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}



