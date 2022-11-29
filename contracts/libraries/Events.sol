// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { DataTypes } from "./DataTypes.sol";

/**
 * @title Events
 * @author API3 Latam
 * 
 * @notice A standard library of Events used across the API3 LATAM
 * Raffle Platform.
 */
library Events {
    /**
     * @dev Emitted when a Raffle is created.
     * 
     * @param _raffleId - The identifier for this specific raffle.
     * @param _raffleMetadata - The actual metadata from the raffle
     * being created.
     */
    event RaffleCreated (
        uint256 indexed _raffleId,
        DataTypes.IndividualRaffle _raffleMetadata
    );

    /**
     * @dev Emitted when a winner is picked trough the QRNG fulfillment.
     *
     * @param _raffleId - The identifier for this specific raffle.
     * @param raffleWinners - The winner address list for this raffle.
     */
    event WinnerPicked (
        uint256 indexed _raffleId,
        address[] raffleWinners
    );
    
    /**
     * @dev Emitted when we set the parameters for the airnode.
     *
     * @param airnodeAddress - The Airnode address being use.
     * @param sponsorAddress - The address from sponsor.
     * @param sponsorWallet - The actual sponsored wallet address.
     */
    event SetRequestParameters (
        address airnodeAddress,
        address sponsorAddress,
        address sponsorWallet
    );

    /**
     * @dev Emitted when a new Endpoint is added to an AirnodeLogic instance.
     *
     * @param _index - The current index for the recently added endpoint in the array.
     * @param _newEndpointId - The given endpointId for the addition.
     * @param _newEndpointSelector - The selector for the given endpoint of this addition.
     */
    event SetAirnodeEndpoint (
        uint256 _index,
        bytes32 _newEndpointId,
        bytes4 _newEndpointSelector
    );

    /**
     * @dev Should be emitted when a request is done.
     *
     * @param requestId - The request id from which this event was emitted.
     * @param endpointId - The endpoint from which this request was originated.
     * @param airnodeAddress - The airnode address from which this request was originated.
     */
    event NewRequest (
        bytes32 indexed requestId,
        bytes32 indexed endpointId,
        address indexed airnodeAddress
    );

    /**
     * @dev Same as `NewRequest` but, emitted at the callback time when
     * a request is successful for flow control.
     *
     * @param requestId - The request id from which this event was emitted.
     * @param endpointId - The endpoint from which this request was originated.
     * @param airnodeAddress - The airnode address from which this request was originated.
     */
    event SuccessfulRequest (
        bytes32 indexed requestId,
        bytes32 indexed endpointId,
        address indexed airnodeAddress
    );
}
