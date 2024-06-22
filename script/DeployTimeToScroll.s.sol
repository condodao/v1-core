// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {NewCondoTimelock} from "@condodao/v1-core/contracts/condo/new/NewCondoTimelock.sol";

/**
nano .env
PRIVATE_KEY=""
ETHERSCAN_API_KEY="verifyContract" 
RPC_URL=https://sepolia-rpc.scroll.io/
VERIFIER_URL=https://api-sepolia.scrollscan.com/api
DEPLOYER="$(cast wallet address --private-key $PRIVATE_KEY)"
source .env

forge script script/DeployTimeToScroll.s.sol \
    --rpc-url $RPC_URL \
    --broadcast \
    --private-key $PRIVATE_KEY \
    --optimize \
    --optimizer-runs 200

forge verify-contract 0xC74620d5e2F26673012dBAC2e57f269397F0429E NewCondoTimelock \
    --verifier-url $VERIFIER_URL \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --constructor-args ""
    
NewCondoTimelock: 0xC74620d5e2F26673012dBAC2e57f269397F0429E
*/
contract DeployToScrollScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        NewCondoTimelock newContract = new NewCondoTimelock();
        console.log("NewCondoTimelock:", address(newContract));

        vm.stopBroadcast();
    }
}
