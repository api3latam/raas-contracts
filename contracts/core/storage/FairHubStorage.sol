// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract FairHubStorage {

    Counters.Counter internal _raffleCounter;       // Individual Raffle identifier

    // Mapping of raffle id with its contract
    mapping(uint256 => address) public raffles;

}
