// SPDX-License-Identifier: UNLICENSED
// If smart contract is modified, it must be deployed again, update contract address and ABI json in our front-end
// npx hardhat run scripts/deploy.js --network rinkeby
// artifacts/contracts/.json file

pragma solidity ^0.8.0; //Indicates what version Solidity compiler we want our contract to use (make sure compiler version is same as in hardhat.config.js)

import "hardhat/console.sol"; //Import helps us console log debug our smart contracts

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;           // Generate a random number

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        //struct data type that holds the address of the user who just waved, message they sent and the timestamp of the wave
        address waver;
        string message;
        uint256 timestamp;
    }

    Wave[] waves;       // List of all wavers addresses

    // Maps an address with a uint256 number
    // Stores the address with the last time the user waved at us
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        // payable modifier allows contract to recieve ether into the contract
        console.log("Smart Contract Constructor!");
        seed = (block.timestamp + block.difficulty) % 100; // Set the initial seed

        // using block.difficulty and block.timestamp
    }

    function wave(string memory _message) public {

        // Check if the current timestamp is at least 15 minutes bigger than the previous timestamp we stored
        require (
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Please wait 15 minutes before trying again."
        );

        // Update the current timestamp we have for the current user
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        seed = (block.difficulty + block.timestamp + seed) % 100; // Generate a new seed for the next user that sends a wave
        // Block difficulty is how hard it is for miners to mine based on the transactions in the block
        // Block timestamp is the Unix timestamp that the block is being processed
        // % `100 makes sure the number is between a range 0 - 100

        console.log("Random number = %d", seed);

        if (seed <= 50) {           // Give the seed a 50% chance that the users wins a prize
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;

            require(
                prizeAmount <= address(this).balance, //Check if the smart contract has enough balance, else the require kills the transaction
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}(""); // Sends money to message sender address
            require(success, "Failed to withdraw money from contract."); // Checks if transactions if a succcess. If not, it marks the transaction as an error and prints error message
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    //Returns the waves struct array
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        // Optional: Add this line if you want to see the contract print the value!
        // We'll also print it over in run.js as well.
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}
