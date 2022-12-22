// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { DataTypes } from '../libraries/DataTypes.sol';
import { Events } from "../libraries/Events.sol";
import { FairHubStorage } from "./storage/FairHubStorage.sol";
import { Raffle } from "./Raffle.sol";
import { RaffleBeacon } from "../upgradeability/RaffleBeacon.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract FairHub is FairHubStorage {
    using Counters for Counters.Counter;

    RaffleBeacon immutable raffleBeacon;

    constructor (
        address _beaconContract
    ) { 
        raffleBeacon = _beaconContract;
    }

    /**
     * @notice Creates a new Raffle Proxy from a given implementation.
     * @dev Uses the beacon to get implementation address.
     */
    function createRaffle (
        address creatorAddress,
        DataTypes.RaffleStatus status,
        uint256 startTime,
        uint256 endTime,
        uint256 winnerNumber,
        DataTyoes.Multihash memory metadata
    ) external {
        _raffleId.increment();
        uint256 _id = _raffleId.current();

        bytes memory _data = abi.encodeWithSelector(
            Raffle.initialize.selector,
            creatorAddress,
            status,
            _id,
            startTime,
            endTime,
            winnerNumber,
            metadata
        )

        BeaconProxy _raffle = new BeaconProxy(
            address(raffleBeacon),
            _data
        );

        raffles[_id] = address(_raffle);

        emit events.RaffleCreated(_id);
    }

}