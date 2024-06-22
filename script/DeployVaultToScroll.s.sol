// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {NewCondoVault} from "@condodao/v1-core/contracts/condo/new/NewCondoVault.sol";

/**
nano .env
PRIVATE_KEY=""
ETHERSCAN_API_KEY="verifyContract" 
RPC_URL=https://sepolia-rpc.scroll.io/
VERIFIER_URL=https://api-sepolia.scrollscan.com/api
DEPLOYER="$(cast wallet address --private-key $PRIVATE_KEY)"
source .env

forge script script/DeployVaultToScroll.s.sol \
    --rpc-url $RPC_URL \
    --broadcast \
    --private-key $PRIVATE_KEY \
    --optimize \
    --optimizer-runs 200

forge verify-contract 0x7D6DBc274728F733078c7abDAC0A3acbB0d8c02c NewCondoVault \
    --verifier-url $VERIFIER_URL \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --constructor-args ""
    
NewCondoVault: 0x7D6DBc274728F733078c7abDAC0A3acbB0d8c02c
*/
contract DeployToScrollScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        NewCondoVault newContract = new NewCondoVault();
        console.log("NewCondoVault:", address(newContract));

        vm.stopBroadcast();
    }
}
