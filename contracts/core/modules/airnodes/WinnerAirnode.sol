// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { DataTypes } from "../../../libraries/DataTypes.sol";
import { Events } from "../../../libraries/Events.sol";

import { AirnodeLogic } from "../../base/AirnodeLogic.sol";

/**
 * @title WinnerAirnode
 * @author API3 Latam
 *
 * @notice This is the contract implementation to pick winners for raffles
 * using the QRNG oracle.
 */
contract WinnerAirnode is AirnodeLogic {

    constructor (
        address _airnodeRrpAddress
    ) AirnodeLogic(
        _airnodeRrpAddress
    ) {}

    /**
     * @notice
     */
    function callAirnode (
        uint256 endpointIdIndex,
        bytes calldata _parameters
    ) external override returns (
        bytes32
    ) {
        DataTypes.Endpoint memory currentEndpoint = endpointIds[endpointIdIndex];
        bytes parameters;

        require(
            _parameters.length >= 0
        );
            
        if (_parameters.length == 0) {
            parameters = "";
        } else if (_parameters.length > 0) {
            parameters = _parameters;
        }

        bytes32 _requestId = airnodeRrp.makeFullRequest(
            airnode,
            currentEndpoint.endpointId,
            sponsorAddress,
            sponsorWallet,
            address(this),
            currentEndpoint.functionSelector,
            parameters
        );

        incomingFulfillments[_requestId] = true;
        requestToEndpoint[_requestId] = endpointIdIndex;
        
        emit Events.NewRequest (
            _requestId,
            currentEndpoint.endpointId,
            airnode
        );
    }

    /**
     * @notice - 
     */
    function pickOneWinner (
        bytes32 requestId, 
        bytes calldata data
    ) external override onlyAirnodeRrp {
        uint256 
    }
}
