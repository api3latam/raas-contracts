// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

/**
 * @title IWinnerAirnode
 * @author API3 Latam
 *
 * @notice This is the interface for the Winner Airnode,
 * which is initialized utilized when closing up a raffle.
 */
interface IWinnerAirnode {

    /**
     * @notice - The function to request this airnode implementation call.
     *
     * @param endpointIdIndex - The target endpoint to use as callback.
     * @param winnerNumbers - The number of winners to return
     * @param participantNumbers - The number of participants from the raffle.
     */
    function requestWinners (
        uint256 endpointIdIndex,
        uint256 winnerNumbers,
        uint256 participantNumbers
    ) external returns (
        bytes32
    );

    /**
     * @notice - Callback function when requesting one winner only.
     * @dev - We suggest to set this as endpointId index `1`.
     *
     * @param requestId - The id for this request.
     * @param data - The response from the API send by the airnode.
     */
    function getIndividualWinner (
        bytes32 requestId,
        bytes calldata data
    ) external;

    /**
     * @notice - Callback function when requesting multiple winners.
     * @dev - We suggest to set this as endpointId index `2`.
     *
     * @param requestId - The id for this request.
     * @param data - The response from the API send by the airnode. 
     */
    function getMultipleWinners (
        bytes32 requestId,
        bytes calldata data
    ) external;

}
