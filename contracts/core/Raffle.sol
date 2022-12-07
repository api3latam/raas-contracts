// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

import { DataTypes } from "../libraries/DataTypes.sol";
import { IRaffle } from "../interfaces/IRaffle.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title Raffle
 * @author API3 Latam
 *
 * @notice This is the implementation of the Raffle contract.
 * Including the logic to operate an individual Raffle.
 */
contract Raffle is IRaffle {

    using Counters for Counters.Counter;

    Counters.Counter private _participantId;    // The current index of the mapping.
    address public creator;                     // The address from the creator of the raffle.
    DataTypes.RaffleStatus public status;       // The status of the raffle.

    address[] public winners;               // Winner addresses for this raffle

    mapping(uint256 => address) public participants; // Id to participants mapping.

    constructor (
        address _creator
    ) {
        creator = _creator;
    }

    function enter (
        address participantAddress
    ) external {
        _participantId.increment();
        participants[_participantId.current()] = participantAddress;
    }

    function close ()
     external {
         
     }

}
