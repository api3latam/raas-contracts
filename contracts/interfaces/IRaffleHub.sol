// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

/**
 * @title IRaffleHub
 * @author API3 Latam
 *
 * @notice This is the interface for the Raffle Manager,
 * The contract from which users will be able to create raffles.
 */
interface IRaffleHub {

    /**
     * @notice Creates a clone for new raffle.
     * @param _startTime Time the raffle starts.
     * @param _endTime Time the raffle ends.
     * @param _id The id from the raffle.
     */
    function create (
        uint256 _startTime,
        uint256 _endTime,
        uint256 _id
    ) external;

    /**
     * @notice Enters a given raffle.
     * @param _id The raffle id.
     * @param _participantAddress The participant address.
     */
    function raffleEnter (
        uint256 _id,
        address _participantAddress
    ) external;

    /**
     * @notice Calls the `close` function from the given raffle.
     *
     * @param _id The raffle id.
     * @param _winnerNumbers The number of winners to pick.
     */
    function raffleClose (
        uint256 _id,
        uint256 _winnerNumbers
    ) external;

    /**
     * @notice Calls the `finish` function from the given raffle.
     *
     * @param _id The raffle id.
     */
    function raffleFinish (
        uint256 _id
    ) external;

    /**
     * @notice Calls the `updateWinners` function from the given raffle.
     *
     * @param _id The raffle id.
     */
    function raffleUpdateWinners (
        uint256 _id,
        uint256 winnerNumber
    ) external;

    /**
     * @notice Get the participants from the given raffle. 
     *
     * @param _id The raffle id.
     */
    function raffleEntries (
        uint256 _id
    ) external view;

    /**
     * @notice Get the winners from the given raffle.
     *
     * @param _id The raffle id.
     */
    function raffleWinners (
        uint256 _id
    ) external view;

    /**
     * @notice Get the raffles an address has participated in.
     *
     * @param _id The raffle id.
     */
    function raffleEntered (
        uint256 _id
    ) external view;
}