// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployFundMe} from "../../scripts/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../scripts/Interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../scripts/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";



contract InteractionsTest is Test {
    FundMe public fundMe;
    HelperConfig public helperConfig;

    uint256 public constant SEND_VALUE = 5 ether; // just a value to make sure we are sending enough!
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    address public constant USER = address(1);

    
    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_USER_BALANCE); // Give USER some ether
    }

    function testUserCanFundAndOwnerWithdraw() public{
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 originalFundMeBalance = address(fundMe).balance;

        // Using vm.prank to simulate funding from the USER address
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE + originalFundMeBalance, afterOwnerBalance);
    }
}