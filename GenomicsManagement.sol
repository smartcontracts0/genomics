// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; 

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

//import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

contract GenomicsDataManagement is ReentrancyGuard{

    using ECDSA for bytes32; //Used for signatures verification

    //**** Variables ****//

    IERC721 private RawNFTSmartContract; //This fixes the smart contract of raw nfts to prevent other smart contracts from interacting
    IERC721 private SequencedNFTSmartContract; //Same as Raw NFT SC
    uint public SequencingPeriod; //Used to create a time window for sequencing genomic data
    uint public FullAccessGrantingPeriod; //Timewindow to grant full access
    uint public LimitedAccessGrantingPeriod; //Timewindow to grant limited access
    address public RegistrationAuthority; //Repsonsible for registering eligible sequencing Centers
    address payable public buyer; //The address of the genomic data buyer
    address payable public dataOwner; // The address of the genomic data owner
    address public SequencedNFTAddress;
    address public LimitedAccessOracle; //This oracle is responsible for updating the number of operations for a buyer
    mapping(address => bool) public sequencingCenter; //A mapping of authorized sequencing centers
    uint public RawNFTsCount; //This is the RawNFTs number within the managment smart contract, not the NFT SC
    uint public SequencedNFTsCount; //This is the RawNFTs number within the managment smart contract, not the NFT SC
    uint public sequencingPrice; //The cost of sequencing a genomic data which is determined by sequencingCenter

    struct RawGenomicNFT{
        uint RawNFTId; //a counter within the SC only
        IERC721 nft; //Necessary to enable transferring nfts when called later on
        uint tokenId; 
        address payable dataOwner;
        address payable sequencingPayer;
        address payable CommittedsequencingCenter; //The address of the sequencing center that commits to the raw genomic data
        bool isSequenced; //Checks if the raw genomic data has been sequenced or not
        bool isPendingSequencing; //Checks if the raw genomic data is in the sequencing process
        uint sequencingStartTime; //The time at which the request for sequencing raw genomic data has started
        bool eligibleForSequencedNFT; //This boolean becomes true if the owner succesfully sequences the genomic data
        uint sequencingcost; //This is necessary to know the value of sequencing at the time of sequencing because it can be updated at any time

    }

    mapping(uint => RawGenomicNFT) public RawNFTs; //Maps each RawGenomicNFT to a unique number within the mgmt SC
    mapping(address => uint) public SequencedNFTMintingBalance; //This mapping tracks the minting balance of each Genomic data NFT owner




    struct SequencedGenomicNFT{
        uint SeqNFTId; //a counter within the SC only
        IERC721 nft2; //Necessary to enable transferring nfts when called later on
        uint tokenId; 
        uint fullaccessprice;
        uint limitedaccessprice; //This is the price for one operation on the encrypted data
        address payable dataOwner; 
        uint pendingrequests; //Tracks the number of full or limited access requests (has to be zero if the owner wants to delist)
    }


    mapping(uint => SequencedGenomicNFT) public SequencedNFTs; //Maps each RawGenomicNFT to a unique number within the mgmt SC

    mapping(uint => mapping(address => uint)) public FullAccessRequestStartingTime; //This is the time at which the request for full access was initiated by a buyer's address
    //mapping(uint => mapping(address => uint)) public LimitedAccessRequestStartingTime; //This is the time at which the request for full access was initiated by a buyer's address


    mapping(uint => mapping(address => bool)) public FullAccessBuyers; //maps the nft id and buyer address to boolean

    mapping(uint => mapping(address => bool)) public LimitedAccessBuyers; 
    mapping(uint => mapping(address => uint)) public LimitedAccessOperationsCounter;

    //**** Signature-Related Variables ****//

    struct SequencingSignature{
        address dataOwner;
        uint RawNFTId;
        IERC721 nft;
        uint tokenId;
        string message;
        bytes sig;
    }
    mapping(uint => SequencingSignature) public sequencingSignatures; //This mapping is for the signatures that confirm that the owner has received the sequenced data from the sequencing center


    struct FullAccessSignature{
        address dataBuyer;
        uint SeqNFTId;
        IERC721 nft2;
        uint tokenId;
        string message;
        bytes sig;
    }
    mapping(uint => FullAccessSignature) public fullaccessSignatures; //This mapping is for the signatures that confirm that the buyer has received the sequenced data for the data owner

    struct LimitedAccessSignature{
        address dataBuyer;
        uint SeqNFTId;
        IERC721 nft2;
        uint tokenId;
        string message;
        bytes sig;
    }
    mapping(uint => LimitedAccessSignature) public limitedaccessSignatures; //This mapping is for the signatures that confirm that the buyer has received the sequenced data for the data owner


    //**** Events ****//
    event ListedRawGenomicNFT(uint RawNFTId, address indexed nft, uint tokenId, address indexed dataOwner);
    event DelistedRawGenomicNFT(uint RawNFTId, address indexed nft, uint tokenId, address indexed dataOwner);
    event RawNFTSequencingPayment(uint RawNFTId, address indexed nft, uint tokenId, address indexed dataOwner, address indexed buyer, uint sequencingStartTime, uint sequencingDeadline);
    event SequencingCenterCommitted(uint RawNFTId, address indexed nft, uint tokenId, address indexed dataOwner, address indexed CommittedsequencingCenter);
    event RawNFTisSequenced(uint RawNFTId, address indexed nft, uint tokenId, address indexed dataOwner, address buyer, address indexed sequencingCenter);
    event DirectSequencingPayment(address indexed dataOwner, uint sequencingStartTime, uint sequencingDeadline);
    event ListedSequencedGenomicNFT(uint SeqNFTId, address indexed nft2 , uint tokenId, address indexed dataOwner, uint fullaccessprice, uint limitedaccessprice); 
    event SequencingSignatureStorage(address indexed verifiedAddress, address indexed dataOwner, address indexed nft, uint tokenId, string message, bytes signature);
    event DelistedSequencedGenomicNFT(uint SeqNFTId, address indexed nft, uint tokenId, address indexed dataOwner);
    event FullAccessRequested(uint SeqNFTId, address indexed nft, uint tokenId, address indexed dataOwner, address indexed fullaccessbuyer);
    event FullAccessGranted(uint SeqNFTId, address indexed nft, uint tokenId, address indexed dataOwner, address indexed dataBuyer);
    event FullAccessSignatureStorage(address indexed verifiedAddress, address indexed dataBuyer, address indexed nft, uint tokenId, string message, bytes signature);
    event LimitedAccessSignatureStorage(address indexed verifiedAddress, address indexed dataBuyer, address indexed nft, uint tokenId, string message, bytes signature);
    event LimitedAccessGranted(uint SeqNFTId, address indexed nft, uint tokenId, address indexed dataOwner, address indexed dataBuyer);





    constructor(uint _SequencingPeriod, uint _sequencingPrice, uint _FullAccessGrantingPeriod, uint _LimitedAccessGrantingPeriod, address _rawNFTaddress, address _seqNFTAddress){
        
        SequencingPeriod = _SequencingPeriod * 1 days; //The period is arbitrarly chosens
        FullAccessGrantingPeriod = _FullAccessGrantingPeriod * 1 days; //The period is arbitrarly chosen
        LimitedAccessGrantingPeriod = _LimitedAccessGrantingPeriod * 1 days; //The period is arbitrarly chosen
        sequencingPrice = _sequencingPrice * 1 ether;
        RegistrationAuthority = msg.sender; //The deployer of the smart contract is the registration authority
        RawNFTSmartContract = IERC721(_rawNFTaddress); //the smart contract address is casted in IERC721 to allow it to access its functionalities such as transfer
        SequencedNFTSmartContract = IERC721(_seqNFTAddress);
    }









    

    //**** Modifiers ****//
    modifier onlySequencingCenter{
      require(sequencingCenter[msg.sender], "Only authorized sequence centers can run this function");
      _;
    }

    modifier onlyRegistrationAuthority{
        require(msg.sender == RegistrationAuthority, "Only the registration authority can run this function");
        _;
    }

    //Confirm that this work while testing
    modifier onlySequencedNFTSC{
        require(msg.sender == address(SequencedNFTSmartContract), "Only the the sequenced NFT smart contract can run this function");
        _;
    }

    modifier onlyLimitedAccessOracle{
        require(msg.sender == LimitedAccessOracle, "Only the LimitedAccessOracle can run this function");
        _;
    }























    //**** Functions ****//
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function RegisterSequencingCenter(address _sequencingCenter) external onlyRegistrationAuthority{
        sequencingCenter[_sequencingCenter] = true;
    }

    function RegisterLimitedAccessOracle(address _LimitedAccessOracle) external onlyRegistrationAuthority{
        LimitedAccessOracle = _LimitedAccessOracle;
    }


    function UpdateSequencingPrice(uint _price) external onlySequencingCenter{
        sequencingPrice = _price * 1 ether;
    }

    //This function only lists the raw genomic NFT so that interested buyer can view it and decide to sequence it or not
    //This function won't work unless the user has an NFT with the specified token ID in the RawNFTSmartContract
    function listRawGenomicNFT(uint _tokenId) external nonReentrant{
        RawNFTSmartContract.transferFrom(msg.sender, address(this), _tokenId); //Transfers the NFT from its owner to the smart contract 
        RawNFTsCount++; 
        RawNFTs[RawNFTsCount] = RawGenomicNFT (RawNFTsCount, RawNFTSmartContract, _tokenId, payable(msg.sender), payable(address(0)), payable(address(0)), false, false, 0, false, sequencingPrice);

        emit ListedRawGenomicNFT(RawNFTsCount, address(RawNFTSmartContract), _tokenId, msg.sender); 
    }

    function delistRawGenomicNFT(uint _RawNFTId) external nonReentrant{
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(msg.sender == Raw.dataOwner, "Only the owner of the Raw Genomic NFT is allowed to delist it");
        require(!Raw.isSequenced, "The Raw Genomic Data has already been sequenced, therefore, it cannot be delisted");
        require(!Raw.isPendingSequencing, "Cannot delist because someone has already paid for sequencing and it is pending");
        Raw.nft.transferFrom(address(this), msg.sender, Raw.tokenId);
        delete RawNFTs[_RawNFTId]; //Removes all entries of the delisted NFT
        emit DelistedRawGenomicNFT(Raw.RawNFTId, address(Raw.nft), Raw.tokenId, msg.sender);
    }

    //This function allows an interested buyer to pay for the sequencing of a raw genomic NFT and gain full access
    //The owner can decide to pay for sequencing and pay for it
    function PayForRawNFTSequencing(uint _RawNFTId) external payable nonReentrant{
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(_RawNFTId > 0 && _RawNFTId <= RawNFTsCount, "The requested NFT doesn't exist");
        require(msg.value >= sequencingPrice, "Not enough ether to cover the sequencing cost");
        require(!Raw.isSequenced && !Raw.isPendingSequencing, "This Raw Genomic Data has already been sequenced or currently being sequenced");
        require(msg.sender != Raw.dataOwner, "The owner of the NFT cannot execute this function"); 

        payable(address(this)).call{value: sequencingPrice}; //The sequencing value remains in the smart contract until the sequencing is completed 
        Raw.sequencingPayer = payable(msg.sender); //This is needed to process the payment for the buyer later on and keep track of him/her
        Raw.isPendingSequencing = true; 
        Raw.sequencingStartTime = block.timestamp; 
        Raw.sequencingcost = sequencingPrice; //This is necessary to ensure that the amount paid in this transaction is stored

        emit RawNFTSequencingPayment(Raw.RawNFTId, address(Raw.nft), Raw.tokenId, Raw.dataOwner, msg.sender, block.timestamp, block.timestamp+SequencingPeriod);

    }

            //This function allows a buyer to withdraw funds if full access is not granted in time
    function withdrawRawNFTSequencingPayment(uint _RawNFTId) external payable nonReentrant{
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(msg.sender == Raw.sequencingPayer, "The caller has not paid for the sequencing of this NFT");
        require(Raw.sequencingStartTime > block.timestamp, "The time window for full access request is still openned");

        payable(msg.sender).call{value: Raw.sequencingcost}; 
        Raw.sequencingPayer = payable(address(0)); //This is needed to process the payment for the buyer later on and keep track of him/her
        Raw.isPendingSequencing = false; 
        Raw.sequencingStartTime = 0; 
        Raw.sequencingcost = sequencingPrice;
    }

    //This function allows sequencing centers to commit to a raw genomic data sequencing
    function CommitToRawNFTSequencing(uint _RawNFTId) external onlySequencingCenter{
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it

        require(Raw.isPendingSequencing == true, "This Raw genomic data is not pending sequencing");
        require(Raw.CommittedsequencingCenter == address(0), "A sequencing center is already committed to sequencing this raw genomic data");

        Raw.CommittedsequencingCenter = payable(msg.sender); //The sequencing center calling this function becomes accountable for this NFT
        
        emit SequencingCenterCommitted(Raw.RawNFTId, address(Raw.nft),  Raw.tokenId,  Raw.dataOwner, msg.sender);


    }


    //Note: The delivery of DNA sample and returning the sequenced genomic data can be traced on-chain, but they are outside the scope of our paper
    //In the diagram, show that the original owner will receive data + minting allowance, whereas the buyer will only receive sequenced data
    function ConfirmRawNFTSequencing(uint _RawNFTId) external payable nonReentrant onlySequencingCenter{
        
        SequencingSignature storage signature = sequencingSignatures[_RawNFTId];
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(block.timestamp <= Raw.sequencingStartTime + SequencingPeriod, "The sequencing time window is already closed");
        require(Raw.CommittedsequencingCenter == msg.sender, "Only the committed sequencing center to this NFT can execute this functioh");
        require(signature.dataOwner == Raw.dataOwner, "The sequencing center cannot prove sequencing raw genomic data without the reception confirmation signature of the owner");

        Raw.isPendingSequencing = false;
        Raw.isSequenced = true;
        Raw.eligibleForSequencedNFT = true; //This means the owner of the NFT can now mint the sequenced genomic data NFT
        payable(msg.sender).call{value: Raw.sequencingcost}; //Transfer the sequencing value to the sequencing center 
        SequencedNFTMintingBalance[Raw.dataOwner] += 1; //The data owner's balance of minting sequenced genomic data NFT is increased by 1

        emit RawNFTisSequenced(Raw.RawNFTId, address(Raw.nft), Raw.tokenId, Raw.dataOwner, Raw.sequencingPayer, msg.sender);


    }



    //This function is accessed by the Sequenced NFT smart contract to update the balance of the owner after a successful mint
    function UpdateSequencedNFTMintingBalance (address _dataOwner) external onlySequencedNFTSC{
        SequencedNFTMintingBalance[_dataOwner] -= 1;
    }


    //This function only lists the sequenced genomic NFT 
    //This function won't work unless the user has an NFT with the specified token ID in the SequencedNFTSmartContract
    function listSequencedGenomicNFT(uint _tokenId, uint _fullaccessprice, uint _limitedaccessprice) external nonReentrant{
        SequencedNFTSmartContract.transferFrom(msg.sender, address(this), _tokenId); //Transfers the NFT from its owner to the smart contract until process is completed
        SequencedNFTsCount++; 
        SequencedNFTs[SequencedNFTsCount] = SequencedGenomicNFT(SequencedNFTsCount, SequencedNFTSmartContract, _tokenId, _fullaccessprice, _limitedaccessprice, payable(msg.sender),0); //new address[](0) is used to initialize an empty array

        emit ListedSequencedGenomicNFT(SequencedNFTsCount, address(SequencedNFTSmartContract), _tokenId, msg.sender, _fullaccessprice, _limitedaccessprice); 
    }

    function delistSequencedGenomicNFT(uint _SeqNFTId) external nonReentrant{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(msg.sender == Sequenced.dataOwner, "Only the owner of the sequenced Genomic NFT is allowed to delist it");
        require(Sequenced.pendingrequests == 0, "Cannot delist while there are pending full/limited access requests");
        Sequenced.nft2.transferFrom(address(this), msg.sender, Sequenced.tokenId);
        delete SequencedNFTs[_SeqNFTId]; //Removes all entries of the delisted NFT
        emit DelistedSequencedGenomicNFT(Sequenced.SeqNFTId, address(Sequenced.nft2), Sequenced.tokenId, msg.sender);
    }

    //When this function is executed, the NFT owner will have to enable the buyer to decrypt the encrypted symmetric key (K) with the buyer's private key by using PRE, which allows the buyer to decrypt the genomic data stored on IPFS using decrypted key "K"
    function requestFullAccess(uint _SeqNFTId) external payable nonReentrant{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(_SeqNFTId > 0 && _SeqNFTId <= SequencedNFTsCount , "The requested NFT does not exist");
        require(msg.value >= Sequenced.fullaccessprice, "Not enough ether to cover the cost of full access");
        require(msg.sender != Sequenced.dataOwner, "The NFT owner cannot execute this function");

        FullAccessBuyers[_SeqNFTId][msg.sender] = true;
        payable(address(this)).call{value: Sequenced.fullaccessprice}; //The value of full access remains in the contract until the owner confirms sending it
        Sequenced.pendingrequests += 1;
        FullAccessRequestStartingTime[_SeqNFTId][msg.sender] = block.timestamp; 
        emit FullAccessRequested(Sequenced.SeqNFTId, address(Sequenced.nft2), Sequenced.tokenId, Sequenced.dataOwner, msg.sender);

    }

    //This function allows a buyer to withdraw funds if full access is not granted in time
    function withdrawFullAccessPayment(uint _SeqNFTId) external payable nonReentrant{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(FullAccessBuyers[_SeqNFTId][msg.sender], "The caller has not paid for full access payment");
        require(FullAccessRequestStartingTime[_SeqNFTId][msg.sender] > block.timestamp, "The time window for full access request is still openned");

        payable(msg.sender).call{value: Sequenced.fullaccessprice}; 
        FullAccessBuyers[_SeqNFTId][msg.sender] = false;
        Sequenced.pendingrequests -= 1;
    }


    function ProofofFullAccess(uint _SeqNFTId) external payable nonReentrant{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        FullAccessSignature storage signature = fullaccessSignatures[_SeqNFTId];

        require(FullAccessBuyers[_SeqNFTId][signature.dataBuyer], "The signer is not one of the full access buyers");
        require(block.timestamp <= FullAccessRequestStartingTime[Sequenced.SeqNFTId][signature.dataBuyer] + FullAccessGrantingPeriod, "The full time access window for this buyer has already closed");
        require(msg.sender == Sequenced.dataOwner, "Only the owner of the Sequenced NFT is allowed to run this function");

        payable(msg.sender).call{value: Sequenced.fullaccessprice}; //The value of the full access is transferred to the owner
        Sequenced.pendingrequests -= 1;

        emit FullAccessGranted(Sequenced.SeqNFTId, address(Sequenced.nft2), Sequenced.tokenId, msg.sender, signature.dataBuyer);

    }



    //This function increases the number of operations the buyer is allowed to perform homomorphically on the encrypted genomic data
    //It is assumed that once the buyer pays for operations, he's allowed to perform operations homomorphically on the data immediatly, therefore, there is no need for ProofofLimitedAccess Function
    function requestLimitedAccess(uint _SeqNFTId, uint _numberofoperations) external payable nonReentrant{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(_SeqNFTId > 0 && _SeqNFTId <= SequencedNFTsCount , "The requested NFT does not exist");
        require(msg.value >= _numberofoperations * Sequenced.limitedaccessprice, "Not enough ether to cover the cost of limited access");
        require(msg.sender != Sequenced.dataOwner, "The NFT owner cannot execute this function");

        //LimitedAccessRequestStartingTime[_SeqNFTId][msg.sender] = block.timestamp;
        LimitedAccessOperationsCounter[_SeqNFTId][msg.sender] +=  _numberofoperations; //The number of permitted operations for the msg.sender for this specific NFT (_SeqNFTId) is increased
        payable(Sequenced.dataOwner).call{value: _numberofoperations * Sequenced.limitedaccessprice}; //The total value should be the requested number of operations * cost/operation

    }


    function UpdateBuyerLimitedAccessOperations(uint _SeqNFTId, uint _numberofexecutedoperations, address _dataBuyer) external onlyLimitedAccessOracle{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        
        LimitedAccessOperationsCounter[Sequenced.SeqNFTId][_dataBuyer] -= _numberofexecutedoperations; // This updates the balance of operations for the limited access buyer

    }

















    //**** Singature Functions ****//

    //Signatures Storage is needed to verify the data owner has received the sequenced data from the sequencing center
    function storeSequencingSignatures(string memory message, uint8 v, bytes32 r, bytes32 s, bytes memory sig, uint _RawNFTId) public {
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId];        
        require(isValidSignature(message, v, r, s) == Raw.dataOwner, "Invalid signature");

        sequencingSignatures[_RawNFTId] = SequencingSignature (Raw.dataOwner, Raw.RawNFTId, Raw.nft, Raw.tokenId, message, sig);

        emit SequencingSignatureStorage(isValidSignature(message, v, r, s), Raw.dataOwner, address(Raw.nft),  Raw.tokenId,  message,  sig);
    }

    //Signatures storage is needed to verify the data buyer has received the sequenced data from the data owner
    function storeFullAccessSignatures(string memory message, uint8 v, bytes32 r, bytes32 s, bytes memory sig, uint _SeqNFTId, address _signer) public {
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(FullAccessBuyers[_SeqNFTId][_signer], "The input signer address must belong to one of the active full access buyers");
        require(isValidSignature(message, v, r, s) == _signer, "Invalid signature");

        fullaccessSignatures[_SeqNFTId] = FullAccessSignature(_signer, Sequenced.SeqNFTId, Sequenced.nft2, Sequenced.tokenId, message, sig);

        emit FullAccessSignatureStorage(isValidSignature(message, v, r, s), _signer, address(Sequenced.nft2),  Sequenced.tokenId,  message,  sig);
    }

        //Signatures storage is needed to verify the data buyer has received the sequenced data from the data owner
    function storeLimitedAccessSignatures(string memory message, uint8 v, bytes32 r, bytes32 s, bytes memory sig, uint _SeqNFTId, address _signer) public {
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(LimitedAccessBuyers[_SeqNFTId][_signer], "The input signer address must belong to one of the active Limited access buyers");
        require(isValidSignature(message, v, r, s) == _signer, "Invalid signature");

        limitedaccessSignatures[_SeqNFTId] = LimitedAccessSignature(_signer, Sequenced.SeqNFTId, Sequenced.nft2, Sequenced.tokenId, message, sig);

        emit LimitedAccessSignatureStorage(isValidSignature(message, v, r, s), _signer, address(Sequenced.nft2),  Sequenced.tokenId,  message,  sig);
    }
    


    // Returns the public address that signed a given string message (Message Signing)
    function isValidSignature(string memory message, uint8 v, bytes32 r, bytes32 s) public pure returns (address signer) {
        // The message header; we will fill in the length next
        string memory header = "\x19Ethereum Signed Message:\n000000";
        uint256 lengthOffset;
        uint256 length;
        assembly {
        // The first word of a string is its length
        length := mload(message)
        // The beginning of the base-10 message length in the prefix
        lengthOffset := add(header, 57)
        }
        // Maximum length we support
        require(length <= 999999);
        // The length of the message's length in base-10
        uint256 lengthLength = 0;
        // The divisor to get the next left-most message length digit
        uint256 divisor = 100000;
        // Move one digit of the message length to the right at a time
        while (divisor != 0) {
        // The place value at the divisor
        uint256 digit = length / divisor;
        if (digit == 0) {
            // Skip leading zeros
            if (lengthLength == 0) {
            divisor /= 10;
            continue;
            }
        }
        // Found a non-zero digit or non-leading zero digit
        lengthLength++;
        // Remove this digit from the message length's current value
        length -= digit * divisor;
        // Shift our base-10 divisor over
        divisor /= 10;
        
        // Convert the digit to its ASCII representation (man ascii)
        digit += 0x30;
        // Move to the next character and write the digit
        lengthOffset++;
        assembly {
            mstore8(lengthOffset, digit)
        }
        }
        // The null string requires exactly 1 zero (unskip 1 leading 0)
        if (lengthLength == 0) {
        lengthLength = 1 + 0x19 + 1;
        } else {
        lengthLength += 1 + 0x19;
        }
        // Truncate the tailing zeros from the header
        assembly {
        mstore(header, lengthLength)
        }
        // Perform the elliptic curve recover operation
        bytes32 check = keccak256(abi.encodePacked(header, message));
        return ecrecover(check, v, r, s); 
  }

}


