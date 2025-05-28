// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
// This script deploys the FundMe contract on the Sepolia testnet
// and uses the Sepolia ETH/USD price feed address.
// The price feed address is hardcoded for simplicity, but in a real-world scenario,
// you would typically retrieve it from a configuration file or a deployment script.

contract DeployFundMe is Script {
    function run() external returns (FundMe) {

        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        // If you want to use the price feed address from the HelperConfig

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed); // Sepolia ETH/USD Price Feed
        vm.stopBroadcast();
        return fundMe;
    }
}
