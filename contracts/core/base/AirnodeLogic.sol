// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { DataTypes } from "../../libraries/DataTypes.sol";
import { Events } from "../../libraries/Events.sol";
import { Errors } from "../../libraries/Errors.sol";

import { RrpRequesterV0 } from "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

/**
 * @title AirnodeLogic
 * @author API3 Latam
 *
 * @notice This is an abstract contract to be inherited by the modules
 * which are going to make use of an Airnode.
 */
abstract contract AirnodeLogic is RrpRequesterV0 {

    address public airnode;              // The address of the QRNG airnode.
    address internal sponsorAddress;     // The address from sponsor of the sponsored wallet.
    address internal sponsorWallet;      // The sponsored wallet address that will pay for fulfillments.
    
    DataTypes.Endpoint[] public endpointsIds; // The storage for endpoints data.
    
    mapping(bytes4 => uint256) public callbackToIndex;      // The mapping of functions to their index in the array.
    mapping(bytes32 => bool) internal incomingFulfillments; // The list of ongoing fulfillments.
    
    /**
     * @notice Validates if the given requestId exists.
     * @dev Is up to each requester how to deal with edge cases
     * of missing requests.
     *
     * @param _requestId The requestId being used.
     */
    modifier validRequest (
        bytes32 _requestId
    ) {
        if (incomingFulfillments[_requestId] != true) {
            revert Errors.RequestIdNotKnown();
        }
        _;
    }

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
        sponsorAddress = _sponsorAddress;
        sponsorWallet = _sponsorWallet;
        emit Events.SetRequestParameters(
            _airnode,
            _sponsorAddress,
            _sponsorWallet
        );
    }

    /**
     * @notice Boilerplate to implement airnode calls.
     * @dev This function should be overwritten to include further
     * pre or post processing of airnode calls with a hook.
     *
     * @param _functionSelector - The target endpoint to use as callback.
     * @param parameters - The data for the API endpoint.
     */
    function callAirnode (
        bytes4 _functionSelector,
        bytes memory parameters
    ) internal virtual returns (
        bytes32
    ) {}

    /**
     * @notice Function to push endpoints to the `endpointsIds` array.
     * @dev Pending adding access control.
     *
     * @param _endpointId - The identifier for the airnode endpoint.
     * @param _endpointFunction - The function selector to point the callback to.
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
        callbackToIndex[_endpointSelector] = endpointsIds.length - 1;

        emit Events.SetAirnodeEndpoint(
            endpointsIds.length - 1,
            _endpointId,
            _endpointFunction,
            _endpointSelector
        );
    }

    /**
     * @notice Checks wether and endpoint exists and
     * if it corresponds with the registered index.
     *
     * @param _selector The function selector to look for.
     */
    function _beforeFullfilment (
        bytes4 _selector
    ) internal virtual returns (
        DataTypes.Endpoint memory
    ) {
        uint256 endpointIdIndex = callbackToIndex[_selector];
        DataTypes.Endpoint memory _currentEndpoint = endpointsIds[endpointIdIndex];

        if (_currentEndpoint.endpointId.length == 0) {
            revert Errors.InvalidEndpointId();
        }

        if (_currentEndpoint.functionSelector != _selector) {
            revert Errors.IncorrectCallback();
        }

        return _currentEndpoint;
    }

    /**
     * @notice - Basic hook for airnode callback functions.
     * @dev - You should manually add them to the specific airnode defined
     * callbacks, and we promote suggest further personalization trough
     * overriding it for each specific need.
     *
     * @param _requestId - The id of the request for this fulfillment.
     * @param _airnodeAddress - The address from the airnode of this fulfillment.
     */
    function _afterFulfillment (
        bytes32 _requestId,
        address _airnodeAddress
    ) internal virtual {
        emit Events.SuccessfulRequest(
            _requestId,
            _airnodeAddress
        );
    }
}