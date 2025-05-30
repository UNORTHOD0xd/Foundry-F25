// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.19;
// 2. Imports

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// 3. Interfaces, Libraries, Contracts
error FundMe__NotOwner(); // Custom error for when a non-owner tries to call a function that is restricted to the owner
// Custom errors are more efficient than require statements with strings, as they save gas and provide better clarity in error handling

/**
 * @title A sample Funding Contract
 * @author Patrick Collins
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    // Type Declarations
    using PriceConverter for uint256; 

    // State variables
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    address public immutable i_owner;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed; 

    // Events (we have none!)

    // Modifiers
    modifier onlyOwner() {
        // require(msg.sender == i_owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    } // This modifier checks if the caller is the owner of the contract, and if not, it reverts with a custom error

    // Functions Order:
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    /// @notice Funds our contract based on the ETH/USD price
    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!"); // This checks if the amount sent in wei is at least the minimum USD value, using the PriceConverter library
        
        s_addressToAmountFunded[msg.sender] += msg.value; // This updates the mapping to track how much each address has funded
        s_funders.push(msg.sender); // This adds the sender's address to the list of funders
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // Transfer vs call vs Send
        // payable(msg.sender).transfer(address(this).balance);
        (bool success,) = i_owner.call{value: address(this).balance}(""); // This sends the entire balance of the contract to the owner
        require(success); // This checks if the transfer was successful, and if not, it reverts the transaction
    }

    function cheaperWithdraw() public onlyOwner {
        address[] memory funders = s_funders;  // This creates a memory array of funders to avoid multiple storage reads, which are more expensive in terms of gas
        // mappings can't be in memory, sorry!
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // payable(msg.sender).transfer(address(this).balance);
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    /**
     * Getter Functions
     */

    /**
     * @notice Gets the amount that an address has funded
     *  @param fundingAddress the address of the funder
     *  @return the amount funded
     */
    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    } // This function returns the version of the price feed contract, which can be useful for ensuring compatibility

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    } // This function returns the address of a funder at a specific index in the funders array

    function getOwner() public view returns (address) {
        return i_owner;
    } // This function returns the owner of the contract, which is set in the constructor

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    } // This function returns the price feed interface, allowing interaction with the price feed contract
}