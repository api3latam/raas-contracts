// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

/**
 * @title RaffleBeacon
 * @author API3 Latam
 *
 * @notice Beacon to be used for proxies when creating a raffle from hub.
 * It points to the latest raffle implementation.
 */
contract RaffleBeacon is Ownable {

    UpgradeableBeacon immutable beacon;
    address public currentImplementation;

    constructor (
        address _initialImplementation
    ) {
        beacon = new UpgradeableBeacon(raffleImplementation);
        transferOwnership(tx.origin);
        currentImplementation = raffleImplementation;
    }

    /**
     * @notice Updates the raffle implementation at the beacon.
     *
     * @param _newImplementation The new contract address for the raffle logic.
     */
    function updateImplementation(
        address _newImplementation
    ) external onlyOnwer {
        beacon.upgradeTo(_newImplementation);
        currentImplementation = _newImplementation;
    }

}
