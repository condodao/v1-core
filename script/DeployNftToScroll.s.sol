// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {NewCondoNFT} from "@condodao/v1-core/contracts/condo/new/NewCondoNFT.sol";

/**
nano .env
PRIVATE_KEY=""
ETHERSCAN_API_KEY="verifyContract" 
RPC_URL=https://sepolia-rpc.scroll.io/
VERIFIER_URL=https://api-sepolia.scrollscan.com/api
DEPLOYER="$(cast wallet address --private-key $PRIVATE_KEY)"
source .env

forge script script/DeployNftToScroll.s.sol \
    --rpc-url $RPC_URL \
    --broadcast \
    --private-key $PRIVATE_KEY \
    --optimize \
    --optimizer-runs 200

forge verify-contract 0x4a356cDa82b1cEb879F49165779efD37606B51C3 NewCondoNFT \
    --verifier-url $VERIFIER_URL \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --constructor-args ""
    
NewCondoNFT: 0x4a356cDa82b1cEb879F49165779efD37606B51C3
*/
contract DeployToScrollScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        NewCondoNFT newContract = new NewCondoNFT();
        console.log("NewCondoNFT:", address(newContract));

        vm.stopBroadcast();
    }
}
