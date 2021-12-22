// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
contract RandomGenerator is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    mapping(bytes32 => address) public requestToAddress;
    mapping(address => uint256) public addressToRandomNumber;
    mapping(address => uint256) public addressToStatus;

    event RandomNumberRecieved(address _address, uint256 _number);
    
    constructor() VRFConsumerBase(0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, 0x326C977E6efc84E512bB9C30f76E30c160eD06FB) public {
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        fee = 0.0001*10**18;
    }
     /** 
     * Requests randomness 
     */
    function requestRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        // The user can request for random number iff he has got 0 discount previous time or on first time
        require(addressToStatus[msg.sender]==0,"Random number for you has been generated");
        bytes32 requestId =  requestRandomness(keyHash, fee);
        requestToAddress[requestId]=msg.sender;
        addressToRandomNumber[msg.sender]=201;
        return requestId;
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 randomResult = (randomness % 200) + 1;
        address addr = requestToAddress[requestId];
        addressToRandomNumber[addr] = randomResult;
        addressToStatus[addr] = 1;
        emit RandomNumberRecieved(addr,randomResult);
    }

    function getMyRandomNumber() public returns(uint256){
        require(addressToRandomNumber[msg.sender]!=201,"Random number not yet generated");
        uint256 temp = addressToRandomNumber[msg.sender];
        emit RandomNumberRecieved(msg.sender,temp);
        return temp;
    }
}
