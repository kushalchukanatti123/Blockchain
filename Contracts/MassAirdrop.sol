// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MassAirdrop is Ownable{
    using Strings for uint256;
    address AAPE_CONTRACT_ADDRESS = 0x54bDeE77c126156f9cEEABaBcCD8268cB95A20Bd;
    constructor(){
    }

    function massDrop(address[] memory _recivers) external onlyOwner{
        uint256 num = _recivers.length;
        uint256 batches = num/10;
        uint256 rem = num%10;
        if(rem!=0){
            batches++;
        }
        
        for(uint256 i=0;i<batches;i++){
            if(i==(batches-1)){
                AAPE_Interface(AAPE_CONTRACT_ADDRESS).mintAngel(rem);
            }else{
                AAPE_Interface(AAPE_CONTRACT_ADDRESS).mintAngel(10);
            }
            
        }
        require(AAPE_Interface(AAPE_CONTRACT_ADDRESS).balanceOf(address(this))>=num,"Failed to mint required number of AAPES");
        uint256[] memory contractTokens = AAPE_Interface(AAPE_CONTRACT_ADDRESS).tokensOfOwner(address(this));
        for(uint256 i=0;i<num;i++){
            require(!isContract(_recivers[i]),string(abi.encodePacked("You are trying to send to a contract. Cross check address at human readable index ", (i+1).toString())));
            AAPE_Interface(AAPE_CONTRACT_ADDRESS).safeTransferFrom(address(this),_recivers[i],contractTokens[i]);
        }
    }
    function onERC721Received(
        address, 
        address, 
        uint256, 
        bytes calldata
    )external returns(bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    } 
    
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

}

interface AAPE_Interface {
   function mintAngel(uint256 _count) external payable;
   function balanceOf(address owner) external view returns (uint256 balance);
   function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function tokensOfOwner(address _owner)
    external
    view
    returns (uint256[] memory); 
}

