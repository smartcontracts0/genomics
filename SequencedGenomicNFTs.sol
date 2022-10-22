// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol"; //Imported in case burning NFTs is used
import "@openzeppelin/contracts/access/Ownable.sol";

contract GenomicDataNFTs is ERC721URIStorage, Ownable{
    uint public tokenCount;
    mapping (address => bool) public whitelist; //only whitelisted addresses can mint NFTs
    constructor () ERC721("Sequenced Genomic Data NFTs", "SGD"){} // The constructor uses the imported ERC721 contract which requires two inputs in its constructor, the name and symbol of the NFT
    
    modifier onlyWhitelisted{
      require(whitelist[msg.sender], "Only whitelisted addresses can run this function");
      _;
    } 

    function WhitelistAddress(address _address) external onlyOwner{
        require(msg.sender != owner(), "The owner of this smart contract is not allowed to mint even if whitelisted");
        whitelist[_address] = true;
    }
    
    function mint(string memory _tokenURI) external onlyWhitelisted returns(uint) {
        tokenCount++;
        _safeMint(msg.sender, tokenCount); 
        _setTokenURI(tokenCount, _tokenURI);
        return(tokenCount);
    } 



}
