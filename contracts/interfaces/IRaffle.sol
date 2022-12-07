// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

interface IRaffle {

    /**
     * @notice Enter the raffle.
     * @param participantAddress The participant address.
     */
    function enter (
        address participantAddress
    ) external;

    /**
     * @notice Closes the ongoing raffle.
     * @dev Called by the owner when the raffle is over.
     * This function stops new entries from registering and will
     * call the `WinnerAirnode`.
     */
    function close () external;

    /**
     * @notice Wrap ups a closed raffle.
     * @dev Called by the `finisher` role.
     * This function updates winner and any missing functionality
     * for wrapping up the raffle.
     */
    function finish () external;

    /**
     * @notice Get the participants from the raffle.
     */
    function getEntries () 
     external view returns (
        address[] memory
    );

    /**
     * @notice Get the winner addresses.
     */
    function getWinner ()
     external view returns (
        address[] memory
    );

}
