// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;


/**
 * @title MockRrpRequesterV0.sol
 * @author API3 Latam
 *
 * @notice This is a modified version from the original API3 Dao implementation
 * build for testing purposes. For the actual contract please refer to their repository.
 * https://github.com/api3dao/airnode/blob/master/packages/airnode-protocol/contracts/rrp/AirnodeRrpV0.sol
 * @dev This is not a contract ready for production. 
 * All the security checks have been removed. 
 */
contract MockRrpRequesterV0 {

    mapping(bytes32 => bytes32) private requestIdToFulfillmentParameters;

    function makeFullRequest (
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata parameters
    ) external returns (
        bytes32 requestId
    ) {

        requestId = keccak256(
            abi.encodePacked(
                address(this),
                msg.sender,
                airnode,
                endpointId,
                sponsor,
                sponsorWallet,
                fulfillAddress,
                fulfillFunctionId,
                parameters
            )
        );
        requestIdToFulfillmentParameters[requestId] = keccak256(
            abi.encodePacked(
                airnode,
                sponsorWallet,
                fulfillAddress,
                fulfillFunctionId
            )
        );
    }

    function fulfill (
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId,
        bytes calldata data
    ) external returns (
        bool callSuccess,
        bytes memory callData
    ) {
        require(
            keccak256(
                abi.encodePacked(
                    airnode,
                    msg.sender,
                    fulfillAddress,
                    fulfillFunctionId
                )
            ) == requestIdToFulfillmentParameters[requestId],
            "Invalid request fulfillment"
        );

        delete requestIdToFulfillmentParameters[requestId];
        (callSuccess, callData) = fulfillAddress.call(
            abi.encodeWithSelector(
                fulfillFunctionId,
                requestId,
                data
            )
        );
    }

    function fail (
        bytes32 requestId,
        address airnode,
        address fulfillAddress,
        bytes4 fulfillFunctionId
    ) external {
        require(
            keccak256(
                abi.encodePacked(
                    airnode,
                    msg.sender,
                    fulfillAddress,
                    fulfillFunctionId
                )
            ) == requestIdToFulfillmentParameters[requestId],
            "Invalid request fulfillment"
        );
        delete requestIdToFulfillmentParameters[requestId];
    }
}
