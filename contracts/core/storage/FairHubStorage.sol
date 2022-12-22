// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract RaffleHubStorage {

    Counters.Counter private _ids;       // Individual Raffle identifier

    // Mapping of raffle id with its contract
    mapping(uint256 => address) public raffles;

}
