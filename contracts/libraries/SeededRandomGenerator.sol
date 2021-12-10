// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Seeded pseudo-random number generator
 * @author Utkarsh Sinha <sinha.karsh@gmail.com>
 * @dev Generates pseudo random numbers that's initialized based on the hash of the seed
 */

library SeededRandomGenerator {
    /**
     * @dev Initialize the random number generator with a seed
     * @param seed The seed to initialize the random number generator
     * @return hashOfSeed The hash of the seed
     */
    function init(string memory seed) internal pure returns (bytes32 hashOfSeed) {
        hashOfSeed = keccak256(abi.encodePacked(seed));
    }

    /**
     * @dev Generate a random integer between given range.  Also rehash the provided seed hash
     * @param currentHashOfSeed The current hash of the seed
     * @param min The minimum value of the random number
     * @param max The maximum value of the random number
     * Returns the random integer and the new hash of the seed
     */
    function randomInt(bytes32 currentHashOfSeed, int min, int max) internal pure returns (int randomNumber, bytes32 newHashOfSeed) {
        newHashOfSeed = keccak256(abi.encodePacked(currentHashOfSeed));

        randomNumber = int(uint(newHashOfSeed) % uint(max - min + 1)) + min;
    }
}