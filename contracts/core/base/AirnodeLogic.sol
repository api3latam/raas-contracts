// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { DataTypes } from "../../libraries/DataTypes.sol";
import { Events } from "../../libraries/Events.sol";

import { RrpRequesterV0 } from "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

/**
 * @title AirnodeLogic
 * @author API3 Latam
 *
 * @notice This is an abstract contract to be inherited by the modules
 * which are going to make use of an Airnode.
 */
abstract contract AirnodeLogic is RrpRequesterV0 {

    address public airnode;             // The address of the QRNG airnode.
    address private sponsorAddress;     // The address from sponsor of the sponsored wallet.
    address private sponsorWallet;      // The sponsored wallet address that will pay for fulfillments.
    
    DataTypes.Endpoint[] public endpointsIds; // The storage for endpoints data.
    
    mapping(bytes32 => bool) public incomingFulfillments; // The list of ongoing fulfillments.

    constructor (
        address _airnodeRrp
    ) RrpRequesterV0 (
        _airnodeRrp
    ) { }

    /** 
     * @notice Sets parameters used in requesting QRNG services.
     * @dev Pending to add access control.
     *
     * @param _airnode - The Airnode address for the QRNG.
     * @param _sponsorAddress - The address from sponsor.
     * @param _sponsorWallet - The actual sponsored wallet address.
     */
    function setRequestParameters (
        address _airnode,
        address _sponsorAddress,
        address _sponsorWallet
    ) external {
        airnode = _airnode;
        sponsorAddress = _sponsorAddres;
        sponsorWallet = _sponsorWallet;
        emit Events.SetRequestParameters(
            _airnode,
            _sponsorAddres,
            _sponsorWallet
        );
    }

    /**
     * @notice Boilerplate to implement airnode calls.
     * @dev This function should be overwritten to include further
     * pre or post processing of airnode calls.
     *
     * @param endpointIdIndex - The index from `endpointIds` array to get the
     * necessary parameters for the call.
     * @param parameters - The data for the API endpoint.
     */
    function callAirnode (
        uint256 endpointIdIndex,
        bytes calldata parameters
    ) external virtual override returns (
        bytes32
    ) {}

    /**
     * @notice Function to push endpoints to the `endpointsIds` array.
     * @dev Pending adding access control.
     *
     * @param _endpointId - The identifier for the airnode endpoint.
     * @param _endpointSelector - The function selector to point the callback to.
     */
    function addNewEndpoint (
        bytes32 _endpointId,
        string memory _endpointFunction
    ) external {
        bytes4 _endpointSelector =  bytes4(keccak256(bytes(_endpointFunction)));

        DataTypes.Endpoint memory endpointToPush = DataTypes.Endpoint(
            _endpointId,
            _endpointSelector
        );

        endpointsIds.push(endpointToPush);

        emit Events.SetAirnodeEndpoint(
            endpointsIds.length - 1,
            _endpointId,
            _endpointSelector,
            _endpointFunction
        );
    }
}