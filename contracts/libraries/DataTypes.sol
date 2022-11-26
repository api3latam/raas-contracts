// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

/**
 * @title DataTypes
 * @author API3 Latam
 * 
 * @notice A standard library of data types used across the API3 LATAM
 * Raffle Platform.
 */
library DataTypes {
    
    /**
     * @notice An enum containing the different states a raffle can use.
     *
     * @param Unintialized - A raffle is created but starting time have
     * yet to arrive.
     * @param Open - A raffle where participants can enter.
     * @param Close - A raffle which has gone past its close time.
     */
    enum RaffleStatus {
        Unintialized,
        Open,
        Close
    }

    /**
     * @notice Structure to efficiently save IPFS hashes.
     * @dev To reconstruct full hash insert `hash_function` and `size` before the
     * the `hash` value. So you have `hash_function` + `size` + `hash`.
     * This gives you a hexadecimal representation of the CIDs. You need to parse
     * it to base58 from hex if you want to use it on a traditional IPFS gateway.
     *
     * @param hash - The hexadecimal representation of the CID payload from the hash.
     * @param hash_function - The hexadecimal representation of multihash identifier.
     * IPFS currently defaults to use `sha2` which equals to `0x12`.
     * @param size - The hexadecimal representation of `hash` bytes size.
     * Expecting value of `32` as default which equals to `0x20`. 
     */
    struct Multihash {
        bytes32 hash
        uint8 hash_function
        uint8 size
    }

    /**
     * @notice Basic metadata for a raffle.
     * @dev The time parameters should be used as UNIX time stamp.
     *
     * @param raffleId - The unique identifier for this raffle.
     * @param status - The current status from the raffle.
     * @param startTime - The time when the raffle should start.
     * @param endTime - The time at which the raffle should be closed.
     * @param winners - List of winners for the raffle.
     * @param entries - The list of participants for this raffle.
     * @param metadataHash - The IPFS hash struct for this raffle.
     * @param airnodeSuccess - If the QRNG called was successful.
     */
    struct IndividualRaffle {
        uint256 raffleId;
        RaffleStatus status;
        uint256 startTime;
        uint256 endTime;
        address[] winners;
        address[] entries;
        bool airnodeSuccess;
    }

}