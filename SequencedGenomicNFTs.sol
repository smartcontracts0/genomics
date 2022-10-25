// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol"; //Imported in case burning NFTs is used
import "@openzeppelin/contracts/access/Ownable.sol";

    interface IGenomicsDataManagment{
        function SequencedNFTMintingBalance(address, uint256) external view returns(uint); //The mapping of SequencedNFTMintingBalance in the mgmt SC automatically creates a getter function 
        function UpdateSequencedNFTMintingBalance(address, uint256) external;
        function LinkChildNFTtoParentNFT(uint256, uint256) external;
    }

contract SequencedGenomicDataNFTs is ERC721URIStorage, Ownable{
    uint public tokenCount;
    IGenomicsDataManagment public GenomicsDataManagement;
    //mapping (address => bool) public whitelist; //only whitelisted addresses can mint NFTs
    constructor () ERC721("Sequenced Genomic Data NFTs", "SGD"){} // The constructor uses the imported ERC721 contract which requires two inputs in its constructor, the name and symbol of the NFT
    
    //modifier onlyWhitelisted{
    //  require(whitelist[msg.sender], "Only whitelisted addresses can run this function");
    //  _;
    //} 

    //function WhitelistAddress(address _address) external onlyOwner{
    //    require(msg.sender != owner(), "The owner of this smart contract is not allowed to mint even if whitelisted");
    //    whitelist[_address] = true;
    //}

    //This function sets the mgmt sc address which has the required balance mapping
    function SetGenomicsDataManagementSC(address _mgmtSC) external onlyOwner{
        GenomicsDataManagement = IGenomicsDataManagment(_mgmtSC);

    }

    //Only data owners with >0 are allowed to execute this function, The balance is checked from the mgmt SC's getter function, then a setter function in the interface is used to update the balance
    function mint(string memory _tokenURI, uint256 _parentID) external returns(uint) {
        require(GenomicsDataManagement.SequencedNFTMintingBalance(msg.sender,_parentID) > 0, "The user is not eligible for minting");
        GenomicsDataManagement.UpdateSequencedNFTMintingBalance(msg.sender, _parentID); //The minting balance of msg.sender is decreased by 1
        tokenCount++;
        _safeMint(msg.sender, tokenCount); 
        _setTokenURI(tokenCount, _tokenURI);
        
        GenomicsDataManagement.LinkChildNFTtoParentNFT(_parentID, tokenCount); //Calls the linkage function in the mgmt smart contract

        return(tokenCount);
    } 

}
