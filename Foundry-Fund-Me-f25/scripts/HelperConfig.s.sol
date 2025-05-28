// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract addresses across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD
// This script allows us to run tests in a network-agnostic way.

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
contract HelperConfig is Script {
    // If we are on a local anvil chain, we deploy mocks
    // Otherwise, we use the address of the deployed contract from a mainnet or testnet
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; // 2000 USD with 8 decimals

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor () {
        if (block.chainid == 11155111) {
            // Sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            // Anvil or other local chain
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address for Sepolia ETH/USD
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Sepolia ETH/USD Price Feed Address
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address for Mainnet ETH/USD
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 // Mainnet ETH/USD Price Feed Address
        });
        return mainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            // If we already have a price feed address, return it
            return activeNetworkConfig;
        }
        // price feed address for Anvil ETH/USD

        //1. Deploy a mock price feed contract
        //2. Use the address of the deployed mock contract

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE); // 2000 USD with 8 decimals
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed) // Use the address of the deployed mock contract
        });
        return anvilConfig;
    }
}