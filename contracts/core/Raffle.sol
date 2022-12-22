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
    address immutable creator;                  // The address from the creator of the raffle.
    uint256 public winnerNumber;                // The number of winners for this raffle.
    uint256 immutable startTime;                // The starting time for the raffle.
    uint256 immutable endTime;                  // The end time for the raffle.
    DataTypes.RaffleStatus public status;       // The status of the raffle.
    DataTypes.Multihash public metadata;        // The metadata information for this raffle.
    
    address public winnerRequester;             // The address of the requester being use.
    bytes32 public requestId;                   // The id for this raffle airnode request.

    address[] public winners;                   // Winner addresses for this raffle.

    mapping(uint256 => address) public participants; // Id to participants mapping.

    modifier isOpen() {
        if (status != DataTypes.RaffleStatus.Open) {
            revert Errors.RaffleNotOpen();
        }
        _;
    }

    modifier isAvailable() {
        if (!(status == DataTypes.RaffleStatus.Unintialized ||
                status == DataTypes.Rafflestatus.Open)) {
            revert Errors.RaffleNotAvailable();
        }
        _;
    }

    /**
     * @notice Initializer function for factory pattern.
     * @dev This replaces the constructor so we can apply do the 'cloning'.
     *
     * @param _creator The raffle creator.
     * @param _status Initial status for the raffle.
     * @param _raffleId The id for this raffle.
     * @param _startTime The starting time for the raffle.
     * @param _endTime The end time for the raffle.
     * @param _winnerNumber The initial number to set as total winners.
     * @param _metadata The `Multihash` information for this raffle metadata.
     */
    function initialize (
        address _creator,
        DataTypes.RaffleStatus _status,
        uint256 _raffleId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _winnerNumber,
        DataTypes.Multihash memory _metadata
    ) external initializer {
        
        if (_initialized) {
            revert Errors.AlreadyInitialized();
        }

        creator = _creator;

        if (!(_status == DataTypes.RaffleStatus.Unintialized ||
                _status == DataTypes.Rafflestatus.Open)) {
            revert Errors.WrongInitializationParams(
                "Raffle: Invalid `status` parameter."
            );
        }
        status = _status;
        raffleId = _raffleId;

        if (_startTime < block.timestamp) {
            revert Errors.WrongInitializationParams(
                "Raffle: Invalid `startTime` parameter."
            )
        }
        startTime = _startTime;

        if (_endTime > _startTime) {
            revert Errors.WrongInitializationParams(
                "Raffle: Invalid `endTime` parameter."
            )
        }
        endTime = _endTime;

        if (_winnerNumber <= 0) {
            revert Errors.WrongInitializationParams(
                "Raffle: Invalid `winnerNumber` parameter."
            )
        }
        winnerNumber = _winnerNumber;

        metadata = _metadata;

        _initialized = true;
    }

    /**
     * @notice Set address for winnerRequester.
     *
     * @param _requester The address of the requester contract.
     */
    function setRequester (
        address _requester
    ) external isAvailable {
        if (winnerRequester == _requester) {
            revert Errors.SameValueProvided();
        }

        winnerRequester = _requester;
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

        requestId = _requestId;
        status = DataTypes.RaffleStatus.Close;
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

        status = DataTypes.RaffleStatus.Finish;

        emit Events.WinnerPicked(
            raffleId,
            winners
        );
    }

    /**
     * @dev See { IRaffle-cancel }.
     */
    function cancel () 
     external override isAvailable {
        status = DataTypes.RaffleStatus.Canceled;
    } 

    /**
     * @dev See { IRaffle-updateWinners }.
     */
    function updateWinners (
        uint256 _winnerNumbers
    ) external override isAvailable {
        if (_winnerNumbers <= 0) {
            revert Errors.InvalidWinnerNumber();
        }

        winnerNumber = _winnerNumbers;
    }

    /**
     * @dev See { IRaffle-updateMetadata }
     */
    function updateMetadata (
        DataTypes.Multihash _metadata
    ) external override isAvailable {
        metadata = _metadata;
    }
}
