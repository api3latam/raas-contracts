// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";
import { DataTypes } from "../../libraries/DataTypes.sol";

abstract contract RaffleHubStorage {
    
    bytes32 private constant RAFFLE_CREATOR = keccak256("RAFFLE_CREATOR");

    Counters.Counter private _ids;       // Individual Raffle identifier

    // Mapping of raffle id with its struct
    mapping(uint256 => DataTypes.IndividualRaffle) public raffles;
    // Mapping of metadata with raffle id
    mapping(uint256 => DataTypes.Multihash) private raffleHashes;

}
