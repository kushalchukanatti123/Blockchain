pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";  
contract whitelist {
    using ECDSA for bytes32;
    event Hash(address hash);
    address admin=0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    function get(address account, uint256 tokenId, bytes calldata signature) external {
        //_verify(_hash(account,tokenId),signature);
        require(_verify(_hash(account,tokenId),signature)," Invalid signature ");

    }
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
     return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function _hash(address _address,uint256 _tokenId) internal pure returns (bytes32){
        return  ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(_tokenId,_address)));
    } 

    function getHash(address _address,uint256 _tokenId)public pure returns (bytes32){
        return  ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(_tokenId,_address)));
    }

    

    function _verify(bytes32 _digest,bytes memory signature) internal returns(bool){
       //emit Hash(ECDSA.recover(_digest,signature));
        return admin==ECDSA.recover(_digest,signature);
    }
}
