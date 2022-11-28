// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { DataTypes } from "./DataTypes.sol";

library Events {
    /**
     * @dev Emmited when a Raffle is created.
     * 
     * @param _raffleId - The identifier for this specific raffle.
     * @param _raffleMetadata - The actual metadata from the raffle
     * being created.
     */
    event RaffleCreated (
        uint256 indexed _raffleId
        DataTypes.IndividualRaffle _raffleMetadata
    );

    /**
     * @dev Emmited when a winner is picked trough the QRNG fulfillment.
     *
     * @param _raffleId - The identifier for this specific raffle.
     * @param raffleWinners - The winner address list for this raffle.
     */
    event WinnerPicked (
        uint256 indexed _raffleId,
        address[] raffleWinners
    );
    
    /**
     * @dev Emmited when we set the parameters for the airnode.
     *
     * @param airnodeAddres - The Airnode address for the QRNG.
     * @param targetEndpoints - Endpoint id use for getting quantum numbers.
     * @param sponsorAddress - The address from sponsor.
     * @param sponsorWallet - The actual sponsored wallet address.
     */
    event SetRequestParameters (
        address airnodeAddress, 
        bytes32 targetEndpoint,
        address sponsorAddress,
        address sponsorWallet
    );
}
