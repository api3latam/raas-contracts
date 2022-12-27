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
        bytes memory _parameters
    ) internal override returns (
        bytes32
    ) {
        DataTypes.Endpoint memory currentEndpoint = _beforeFullfilment(
            _functionSelector
        );

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

        return _requestId;
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
        bytes32 requestId;

        if (winnerNumbers == 1) {
            requestId = callAirnode(
                callbackSelector,
                ""
            );
        } else {
            requestId = callAirnode(
                callbackSelector,
                abi.encode(bytes32("1u"), bytes32("size"), winnerNumbers)
            );
        }

        requestToRaffle[requestId].totalEntries = participantNumbers;
        requestToRaffle[requestId].totalWinners = winnerNumbers;

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
        
        uint256[] memory qrngUint256Array = abi.decode(data, (uint256[]));
        uint256[] memory winnersIndexArray;

        for (uint256 i; i < raffleData.totalWinners; i++) {
            winnersIndexArray[i] = qrngUint256Array[i] % raffleData.totalEntries;
        }

        requestToRaffle[requestId].winnerIndexes = winnersIndexArray;

        _afterFulfillment(
            requestId,
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
