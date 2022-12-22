// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

/**
 * @title IRaffle
 * @author API3 Latam
 *
 * @notice This is the interface for the Raffle contract,
 * which is initialized everytime a new raffle is requested.
 */
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
     * @dev This function updates the winners as result from calling the airnode.
     */
    function finish () external;

    /**
     * @notice Cancel an available raffle.
     */
    function cancel () external;

    /**
     * @notice Update the set number of winners.
     *
     * @param _winnerNumbers The new number of winners for this raffle.
     */
    function updateWinners(
      uint256 _winnerNumbers
    ) external;

    /**
     * @notice Update the metadata for the raffle.
     *
     * @param _metadata The new metadata struct.
     */
    function updateMetadata(
      DataTypes.Multihash _metadata
    ) external;
}
