// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { DataTypes } from "../libraries/DataTypes.sol";
import { AirnodeLogic } from "../core/base/AirnodeLogic.sol";

/**
 * @title MockAirnodeLogic
 * @author API3 Latam
 *
 * @notice This mock contract intends to be used for testing the logic
 * behind the AirnodeLogic without taking into account the specifics of
 * an airnode implementation.
 */
contract MockAirnodeLogic is AirnodeLogic {

    constructor (
        address _airnodeRrpAddress
    ) AirnodeLogic (
        _airnodeRrpAddress
    ) {}

    function mockValidRequestModifier(
        bytes32 requestId_
    ) external view validRequest(requestId_) {}

    function mockBeforeFullfilment (
        bytes4 selector_
    ) external returns (
        DataTypes.Endpoint memory
    ) {
        DataTypes.Endpoint memory hookResult = _beforeFullfilment(
            selector_
        );

        return hookResult;
    }

    function mockAfterFulfillment (
        bytes32 requestId_,
        address airnodeAddress_
    ) external {
        _afterFulfillment(
            requestId_,
            airnodeAddress_
        );
    }

}
