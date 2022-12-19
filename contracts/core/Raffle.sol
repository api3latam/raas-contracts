// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { DataTypes } from "../libraries/DataTypes.sol";
import { Events } from "../libraries/Events.sol";
import { Errors } from "../libraries/Errors.sol";
import { IRaffle } from "../interfaces/IRaffle.sol";
import { IWinnerAirnode } from "../interfaces/IWinnerAirnode.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title Raffle
 * @author API3 Latam
 *
 * @notice This is the implementation of the Raffle contract.
 * Including the logic to operate an individual Raffle.
 */
contract Raffle is IRaffle, Initializable {

    using Counters for Counters.Counter;

    Counters.Counter private _participantId;    // The current index of the mapping.
    uint256 immutable raffleId;                 // The id of this raffle contract.
    uint256 winnerNumber;                       // The number of winners for this raffle
    address public winnerRequester;             // The address of the requester being use.
    bytes32 public requestId;                   // The id for this raffle airnode request.
    address public creator;                     // The address from the creator of the raffle.
    DataTypes.RaffleStatus public status;       // The status of the raffle.

    address[] public winners;                   // Winner addresses for this raffle.

    mapping(uint256 => address) public participants; // Id to participants mapping.

    modifier isOpen() {
        if (status != DataTypes.RaffleStatus.Open) {
            revert Errors.RaffleNotOpen();
        }
        _;
    }

    /**
     * @notice Initializer function for factory pattern.
     * @dev This replaces the constructor so we can apply do the 'cloning'.
     *
     * @param _creator - The raffle creator.
     * @param _status - Initial status for the raffle.
     * @param _raffleId - The id for this raffle.
     */
    function initialize (
        address _creator,
        DataTypes.RaffleStatus _status,
        uint256 _raffleId
    ) external initializer {
        require(
            !_initialized,
            "Raffle: Contract has been initialized!"
        );

        _initialized = true;

        creator = _creator;
        status = _status;
        raffleId = _raffleId;
    }

    /**
     * @notice Set address for winnerRequester.
     *
     * @param _requester The address of the requester contract.
     */
    function setRequester (
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
    function close ()
     external override isOpen {
        IWinnerAirnode airnode = IWinnerAirnode(winnerRequester);
        bytes32 _requestId; 
        
        if (winnerNumber == 1) {
            _requestId = airnode.requestWinners (
                airnode.getIndividualWinner.selector, 
                winnerNumber, 
                _participantId.current()
            );
        } else {
            _requestId = airnode.requestWinners (
                airnode.getMultipleWinners.selector, 
                winnerNumber, 
                _participantId.current()
            );
        }

        status = DataTypes.RaffleStatus.Close;
        requestId = _requestId;
    }

    /**
     * @dev See { IRaffle-finish }.
     */
    function finish () 
     external override {
        IWinnerAirnode airnode = IWinnerAirnode(winnerRequester);

        if (status != DataTypes.RaffleStatus.Close) {
            revert Errors.RaffleNotClose();
        }

        DataTypes.WinnerReponse memory winnerResults =  airnode.requestResults(requestId);

        for (uint256 i; i < winnerNumber; i++) {
            winners.push(
                participants[winnerResults.winnerIndexes[i]]
            );
        }

        emit Events.WinnerPicked(
            raffleId,
            winners
        );
    }

    /**
     * @dev See { IRaffle-updateWinners }.
     */
    function updateWinners (
        uint256 _winnerNumbers
    ) external isOpen {
        if (_winnerNumbers <= 0) {
            revert Errors.InvalidWinnerNumber();
        }

        winnerNumber = _winnerNumbers;
    }
}
