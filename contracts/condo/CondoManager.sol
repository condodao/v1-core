// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CondoCondo} from "@condodao/v1-core/contracts/condo/extensions/CondoCondo.sol";
import {CondoApart} from "@condodao/v1-core/contracts/condo/extensions/CondoApart.sol";
import {CondoUser} from "@condodao/v1-core/contracts/condo/extensions/CondoUser.sol";
import {CondoRating} from "@condodao/v1-core/contracts/condo/extensions/CondoRating.sol";
import {CondoShare} from "@condodao/v1-core/contracts/condo/extensions/CondoShare.sol";
import {CondoRent} from "@condodao/v1-core/contracts/condo/extensions/CondoRent.sol";

contract CondoManager is
    CondoCondo,
    CondoApart,
    CondoRating,
    CondoShare,
    CondoRent
{
    constructor() {}
}
