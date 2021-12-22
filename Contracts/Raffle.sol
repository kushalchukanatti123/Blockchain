//SPDX-License-Identifier:MIT
pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Raffle is VRFConsumerBase {

    uint256 internal fee;
    uint256 public randomResult;
    event RandomNumberRecieved(address _address, uint256 _number);



    uint private chosenNumber;
    address winnerParticipant;
    uint maxParticipants;
    uint minParticipants;
    uint joinedParticipants;
    address organizer;
    bool raffleFinished = false;
    address[] participants;
    mapping (address => bool) participantsMapping;
    event ChooseWinner(uint _chosenNumber,address winner);
    event Received(address, uint);
    event RandomNumberGenerated(uint);
    constructor() VRFConsumerBase(0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, 0x326C977E6efc84E512bB9C30f76E30c160eD06FB){ 
        uint8 _min = 2; 
        uint8 _max = 10; 
        require(_min < _max && _min >=2 && _max <=50);
        organizer = msg.sender;
        chosenNumber = _max+1;
        maxParticipants = _max;
        minParticipants = _min;

        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        fee = 0.0001*10**18;
    }

    function joinraffle() external{
        require(!raffleFinished);
        require(msg.sender != organizer);
        require(joinedParticipants + 1 < maxParticipants);
        require(!participantsMapping[msg.sender]);
        participants.push(msg.sender);
        participantsMapping[msg.sender] = true;
        joinedParticipants ++;
    }
    function chooseWinner(uint _chosenNum) internal{
        chosenNumber = _chosenNum;
        winnerParticipant = participants[chosenNumber];
        emit ChooseWinner(chosenNumber,participants[chosenNumber]);
    }
    function generateRandomNum() external{
        require(!raffleFinished);
        require(joinedParticipants >=minParticipants && joinedParticipants<=maxParticipants);
        raffleFinished=true;
        
        chooseWinner(0); //We'll replace this with a call to Oraclize service later on.
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    //Random number functions
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }
}
