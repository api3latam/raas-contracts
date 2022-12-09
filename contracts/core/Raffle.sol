// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

import { DataTypes } from "../libraries/DataTypes.sol";
import { Errors } from "../libraries/Errors.sol";
import { IRaffle } from "../interfaces/IRaffle.sol";
import { IWinnerAirnode } from "../interfaces/IWinnerAirnode.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title Raffle
 * @author API3 Latam
 *
 * @notice This is the implementation of the Raffle contract.
 * Including the logic to operate an individual Raffle.
 */
contract Raffle is IRaffle {

    using Counters for Counters.Counter;

    Counters.Counter private _participantId;    // The current index of the mapping.
    address public winnerRequester;             // The address of the requester being use.
    address public creator;                     // The address from the creator of the raffle.
    DataTypes.RaffleStatus public status;       // The status of the raffle.

    address[] public winners;                   // Winner addresses for this raffle

    mapping(uint256 => address) public participants; // Id to participants mapping.

    modifier isOpen() {
        if (status != DataTypes.RaffleStatus.Open) {
            revert Errors.RaffleNotOpen();
        }
        _;
    }

    constructor (
        address _creator,
        DataTypes.RaffleStatus _status
    ) {
        creator = _creator;
        status = _status;
    }

    /**
     * @notice Set address for winnerRequester.
     *
     * @param _requester The address of the requester contract.
     */
    function setRequester(
        address _requester
    ) external {
        if (winnerRequester != _requester) {
            winnerRequester = _requester;
        } else {
            revert Errors.SameValueProvided();
        }
    }

    /**
     * @dev See { IRaffle-enter }.
     */
    function enter (
        address participantAddress
    ) external override isOpen {
        participants[_participantId.current()] = participantAddress;
        _participantId.increment();
    }

    /**
     * @dev See { IRaffle-close }.
     */
    function close (
        uint256 _winnerNumbers
    )
     external override isOpen returns (
        bytes32
    ) {
        IWinnerAirnode airnode = IWinnerAirnode(winnerRequester);
        bytes32 _requestId;

        if (_winnerNumbers < 0) {
            revert Errors.InvalidWinnerNumber();
        } 
        
        if (_winnerNumbers == 1) {
            _requestId = airnode.requestWinners (
                airnode.getIndividualWinner.selector, 
                _winnerNumbers, 
                _participantId.current()
            );
        } else {
            _requestId = airnode.requestWinners (
                airnode.getMultipleWinners.selector, 
                _winnerNumbers, 
                _participantId.current()
            );
        }

        return _requestId;
    }

}
