// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { DataTypes } from "../../../libraries/DataTypes.sol";
import { Events } from "../../../libraries/Events.sol";
import { Errors } from "../../../libraries/Errors.sol";

import { AirnodeLogic } from "../../base/AirnodeLogic.sol";
import { IWinnerAirnode } from "../../../interfaces/IWinnerAirnode.sol";

/**
 * @title WinnerAirnode
 * @author API3 Latam
 *
 * @notice This is the contract implementation to pick winners for raffles
 * using the QRNG oracle.
 * @dev Pending access control for Raffle Role. To modify `requestToRaffle`.
 */
contract WinnerAirnode is AirnodeLogic, IWinnerAirnode {

    mapping(bytes32 => DataTypes.WinnerReponse) internal requestToRaffle;   // Raffle airnode metadata for each request.

    constructor (
        address _airnodeRrpAddress
    ) AirnodeLogic(
        _airnodeRrpAddress
    ) {}

    /**
     * @dev See { AirnodeLogic-callAirnode }.
     */
    function callAirnode (
        bytes4 _functionSelector,
        bytes calldata _parameters
    ) internal override returns (
        bytes32
    ) {
        _beforeFullfilment(_functionSelector);

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
     * @dev See { IWinnerAirnode-requestWinners }.
     */
    function requestWinners (
        bytes4 callbackSelector,
        uint256 winnerNumbers,
        uint256 participantNumbers
    ) external override returns (
        bytes32
    ) {
        bytes memory parameters;

        if (winnerNumbers == 1) {
            parameters = "";
        } else {
            parameters = abi.encode(bytes32("1u"), bytes32("size"), winnerNumbers);
        }

        bytes32 requestId = callAirnode (
            callbackSelector,
            parameters
        );

        DataTypes.WinnerReponse memory initResponse = DataTypes.WinnerReponse (
            winnerNumbers,
            participantNumbers,
            uint256[winnerNumbers],
            false
        );
        requestToRaffle[requestId] = initResponse;

        emit Events.NewWinnerRequest(
            requestId,
            airnode
        );

        return requestId;
    }

    /**
     * @dev See { IWinnerAirnode-getIndividualWinner }.
     */
    function getIndividualWinner (
        bytes32 requestId,
        bytes calldata data
    ) external virtual override onlyAirnodeRrp validRequest(requestId) {

        uint256 qrngUint256 = abi.decode(data, (uint256));

        DataTypes.WinnerReponse memory raffleData = requestToRaffle[requestId];

        uint256 winnerIndex = qrngUint256 % raffleData.totalEntries;

        requestToRaffle[requestId].winnerIndexes.push(winnerIndex);

        _afterFulfillment(
            requestId,
            raffleData.endpointIndex,
            airnode
        );
    }

    /**
     * @dev See { IWinnerAirnode-getMultipleWinners }.
     */
    function getMultipleWinners (
        bytes32 requestId,
        bytes calldata data
    ) external virtual override onlyAirnodeRrp validRequest(requestId) {

        DataTypes.WinnerReponse memory raffleData = requestToRaffle[requestId];

        uint256[raffleData.totalWinners] qrngUint256Array = abi.decode(data, (uint256[]));
        uint256[raffleData.totalWinners] winnersIndexArray;

        for (uint256 i; i < qrngUint256Array.length; i++) {
            winnersIndexArray[i] = qrngUint256Array[i] % raffleData.totalEntries;
        }

        requestToRaffle[requestId].winnerIndexes = winnersIndexArray;

        _afterFulfillment(
            requestId,
            raffleData.endpointIndex,
            airnode
        );
    }

    /**
     * @dev See { IWinnerAirnode-requestResults }
     */
    function requestResults(
        bytes32 requestId
    ) external override returns (
        DataTypes.WinnerReponse memory
    ) {
        DataTypes.WinnerReponse memory result = requestToRaffle[requestId];

        if (result.isFinished) {
            revert Errors.ResultRetrieved();
        }

        requestToRaffle[requestId].isFinished = true;
        
        return result;
    }

}
