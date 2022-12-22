// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

/**
 * @title Errors
 * @author API3 Latam
 * 
 * @notice A standard library of error types used across the API3 LATAM
 * Raffle Platform.
 */
library Errors {

    // Core Errors
    error SameValueProvided();
    error AlreadyInitialized();
    error WrongInitializationParams(string errorMessage);

    // Raffle Errors
    error RaffleNotOpen();
    error RaffleNotAvailable();
    error RaffleNotClose();

    // Airnode Module
    error RequestIdNotKnown();
    error InvalidEndpointId();
    error IncorrectCallback();
    error InvalidWinnerNumber();    // WinnerAirnode
    error ResultRetrieved();        // WinnerAirnode

}