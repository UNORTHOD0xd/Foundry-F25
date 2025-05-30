// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) { //function parameter accepts an AggregatorV3Interface address
        (, int256 answer, , ,) = priceFeed.latestRoundData(); // get the latest price data from the aggregator
        // ETH/USD rate in 18 digit
        return uint256(answer * 10000000000);
    } // get the latest price of ETH in USD, multiplied by 10^10 to adjust for decimals

    // 1000000000
    // call it get fiatConversionRate, since it assumes something about decimals
    // It wouldn't work for every aggregator
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); // get the ETH price in USD 
        // ethAmount is in wei, which is 10^18 units of ETH
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000; 
        // the actual ETH/USD conversation rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }
}