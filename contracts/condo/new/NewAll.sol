// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {NewCondoGovernor} from "@condodao/v1-core/contracts/condo/new/NewCondoGovernor.sol";
import {NewCondoNFT} from "@condodao/v1-core/contracts/condo/new/NewCondoNFT.sol";
import {NewCondoTimelock} from "@condodao/v1-core/contracts/condo/new/NewCondoTimelock.sol";
import {NewCondoVault} from "@condodao/v1-core/contracts/condo/new/NewCondoVault.sol";

contract NewAll is
    NewCondoGovernor,
    NewCondoNFT,
    NewCondoTimelock,
    NewCondoVault
{
    constructor() {}
}
