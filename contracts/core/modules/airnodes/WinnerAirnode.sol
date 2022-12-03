// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { DataTypes } from "../../../libraries/DataTypes.sol";
import { Events } from "../../../libraries/Events.sol";
import { Errors } from "../../../libraries/Errors.sol";

import { AirnodeLogic } from "../../base/AirnodeLogic.sol";

/**
 * @title WinnerAirnode
 * @author API3 Latam
 *
 * @notice This is the contract implementation to pick winners for raffles
 * using the QRNG oracle.
 */
contract WinnerAirnode is AirnodeLogic {

    mapping(bytes32 => DataTypes.WinnerReponse) internal requestToRaffle; // Raffle airnode metadata for each request.

    constructor (
        address _airnodeRrpAddress
    ) AirnodeLogic(
        _airnodeRrpAddress
    ) {}

    /**
     * @notice Core logic for calling airnode rrp protocol.
     *
     * @param _endpointIdIndex - The target endpoint to use as callback.
     * @param _parameters - The payload for the API from the airnode.
     */
    function callAirnode (
        uint256 _endpointIdIndex,
        bytes calldata _parameters
    ) internal override returns (
        bytes32
    ) {
        DataTypes.Endpoint memory currentEndpoint = endpointIds[endpointIdIndex];

        bytes32 _requestId = airnodeRrp.makeFullRequest(
            airnode,
            currentEndpoint.endpointId,
            sponsorAddress,
            sponsorWallet,
            address(this),
            currentEndpoint.functionSelector,
            _parameters
        );

        incomingFulfillments[_requestId] = true;
    }

    /**
     * @notice - The interface to request this airnode implementation call.
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
    ) {
        bytes memory parameters;

        if (winnerNumbers < 0) {
            revert Errors.InvalidWinnerNumber();
        } else if (winnerNumbers == 1) {
            parameters = "";
        } else {
            parameters = abi.encode(bytes32("1u"), bytes32("size"), winnerNumbers);
        }

        bytes32 requestId = callAirnode (
            endpointIdIndex,
            parameters
        );

        DataTypes.WinnerReponse memory initResponse = DataTypes.WinnerReponse(
            winnerNumbers,
            participantNumbers,
            uint256[winnerNumbers]
        );
        requestToRaffle[requestId] = initResponse;

        emit Events.NewWinnerRequest(
            requestId,
            airnode
        );

        return requestId;
    }

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
    ) external virtual onlyAirnodeRrp validRequest(requestId) {

        uint256 qrngUint256 = abi.decode(data, (uint256));

        DataTypes.WinnerReponse memory raffleData = requestToRaffle[requestId];

        uint256 winnerIndex = qrngUint256 % raffleData.totalEntries;

        requestToRaffle[requestId].winnerIndexes.push(winnerIndex);
    }

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
    ) external virtual onlyAirnodeRrp validRequest(requestId) {

        DataTypes.WinnerReponse memory raffleData = requestToRaffle[requestId];

        uint256[raffleData.totalWinners] qrngUint256Array = abi.decode(data, (uint256[]));
        uint256[raffleData.totalWinners] winnersIndexArray;

        for (uint256 i; i < qrngUint256Array.length; i++) {
            winnersIndexArray[i] = qrngUint256Array[i] % raffleData.totalEntries;
        }

        requestToRaffle[requestId].winnerIndexes = winnersIndexArray;
    }
}
