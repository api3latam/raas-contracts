// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { DataTypes } from "./DataTypes.sol"; 

library Events {
    /**
     * @dev Emmited when a Raffle is created.
     * 
     * @param
     */
    event RaffleCreated(
        DataTypes.IndividualRaffle _raffleMetadata
    );

    /*
     * @
     */
    event WinnerPicked(uint256 indexed _raffleId, address raffleWinner);
    
    /*
     * @
     */
    event SetRequestParameters (
        address airnodeAddress, 
        bytes32 targetEndpoint, 
        address sponsorAddress
    );
}
