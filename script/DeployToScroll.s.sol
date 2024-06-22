// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {CondoManager} from "@condodao/v1-core/contracts/condo/CondoManager.sol";

/**
nano .env
PRIVATE_KEY=""
ETHERSCAN_API_KEY="verifyContract" 
RPC_URL=https://sepolia-rpc.scroll.io/
VERIFIER_URL=https://api-sepolia.scrollscan.com/api
DEPLOYER="$(cast wallet address --private-key $PRIVATE_KEY)"
source .env

forge script script/DeployToScroll.s.sol \
    --rpc-url $RPC_URL \
    --broadcast \
    --private-key $PRIVATE_KEY \
    --optimize \
    --optimizer-runs 200

forge verify-contract 0x16fB02E94f738Cf9659550Eb2059F55B26238315 CondoManager \
    --verifier-url $VERIFIER_URL \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --constructor-args ""
    
CondoManager: 0x16fB02E94f738Cf9659550Eb2059F55B26238315
*/
contract DeployToScrollScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        CondoManager condoManager = new CondoManager();
        console.log("CondoManager:", address(condoManager));

        vm.stopBroadcast();
    }
}
