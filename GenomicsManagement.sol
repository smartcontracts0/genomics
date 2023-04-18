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
    uint256 public SequencingPeriod; //Used to create a time window for sequencing genomic data
    uint256 public InitialFullAccessGrantingPeriod; //The time window for the owner to grant access for the initial buyer
    uint256 public FullAccessGrantingPeriod; //Timewindow to grant full access
    uint256 public LimitedAccessGrantingPeriod; //Timewindow to grant limited access
    address public RegistrationAuthority; //Repsonsible for registering eligible sequencing Centers
    //address payable public buyer; //The address of the genomic data buyer
    //address payable public dataOwner; // The address of the genomic data owner
    //address public SequencedNFTAddress;
    address public LimitedAccessOracle; //This oracle is responsible for updating the number of operations for a buyer
    mapping(address => bool) public sequencingCenter; //A mapping of authorized sequencing centers
    uint256 public RawNFTsCount; //This is the RawNFTs number within the managment smart contract, not the NFT SC
    uint256 public SequencedNFTsCount; //This is the RawNFTs number within the managment smart contract, not the NFT SC
    

    //RawGenomicNFT Variables//
    struct RawGenomicNFT{
        uint256 RawNFTId; //a counter within the SC only
        IERC721 nft; //Necessary to enable transferring nfts when called later on
        uint256 tokenId; 
        address payable dataOwner;
        //bool minted; //Checks if the NFT is minted or not (needed 
        uint256 sequencingcost1; //Method1 cost This is necessary to know the value of sequencing at the time of sequencing because it can be updated at any time
        uint256 sequencingcost2; //Method2 cost
        uint256 sequencingcost3; //Method3 cost
    }

    //Method number => price/cost
    mapping(uint256 => uint256) public SequencingMethodPrice; //Mapping each sequecning method to its corresponding price

    // NFT count => struct 
    mapping(uint256 => RawGenomicNFT) public RawNFTs; //Maps each RawGenomicNFT to a unique number within the mgmt SC

    //buyer address => (NFT count => paid amount)
    mapping(address => mapping(uint256 => uint256)) public sequencingRequesterPaidAmount; //Tracks the paid amount by addresses of buyers who made sequencing payments for RAWNFTId (assuming same address cant make more than one payment to the same NFT at the same time
    
    //NFT Count => sequence number
    mapping(uint256 => uint256) public SequencingRequestsCounter; //Stores the number of request and it keeps going up and cannot be changed manually

    //NFT Count => Security Deposit value
    mapping(uint256 => uint256) public SecurityDepositValue; //Stores the value of the security deposit for a listed NFT [No need to map the address as each NFT has a unique counter and cannot be replicated by other entities]

    //NFT count => mapping(request number => buyer address)
    mapping(uint256 => mapping(uint256 => address)) public SequenceRequesterAddress; //Stores the address of the buyer who requested sequencing

    
    //NFT count => (buyer address => request number)
    mapping(uint256 => mapping(address => uint256)) public SequencingRequestNumberPerBuyer; //The buyer address is necessary becauase new buyers might come after and mess up the counter

    //NFT count => active sequencing requests
    mapping(uint256 => uint256) public ActiveSequencingRequests; 

    //NFT count => active initial full access requests
    mapping(uint256 => uint256) public ActiveInitialFullAccessRequests;

    //buyer address => (NFT count => bool)
    mapping(address => mapping(uint256 => bool)) public sequencingPayerTracker; //Tracks the addresses of buyers who made sequencing payments for RAWNFTId (assuming same address cant make more than one payment to the same NFT at the same time)
    
    //NFT count => (Request number => sequencing method)
    mapping(uint256 => mapping(uint256 => uint256)) public RequestedSequencingMethod;
    
    //NFT count => (requestnumber => sequencing center address)
    mapping(uint256 => mapping(uint256 => address)) public CommittedsequencingCenter;

    //NFT count => (request number => starting time)
    mapping(uint256 => mapping(uint256 => uint256)) public SequencingRequestStartTime;

    //NFT Count => (request number => bool)
    mapping(uint256 => mapping(uint256 => bool)) public SequencingRequestNumberExist; //Checks if the sequencing request number exists or not



    //NFT count => (request number => bool)
    mapping(uint256 => mapping(uint256 => bool)) public SequencingRequestCompleted; //Checks if the sequencing request has been fulfilled or not (important to check before allowing the buyer to withdraw funds)


    //Owner address => (NFT count => sequenced nft minting balance)
    mapping(address => mapping(uint256 => uint256)) public SequencedNFTMintingBalance; //This mapping tracks the minting balance of each Genomic data NFT owner for a specific token ID 



    //SequencedGenomicNFT Variables//
    struct SequencedGenomicNFT{
        uint256 SeqNFTId; //a counter within the SC only
        IERC721 nft2; //Necessary to enable transferring nfts when called later on
        address payable dataOwner; 
        uint256 tokenId; 
        uint256 fullaccessprice; //It is assumed that the price for full access is fixed but it can be decided in an auction if needed
        uint256 limitedaccessprice; //This is the price for one operation on the encrypted data
    }


    //NFT count => struct
    mapping(uint256 => SequencedGenomicNFT) public SequencedNFTs; //Maps each SequencedGenomicNFT to a unique number within the mgmt SC

    //NFT count => active request numbers
    mapping(uint256 => uint256) public ActiveSequencedNFTAccessRequests;



    //NFT Composability Variables and Mappings//

    // SequencedNFTAddress => RawNFTAddress
    mapping(address => address) public childToParentAddress; //Maps the child address to the parent address

    //SequencedNFTAddress => (Child ID => Parent ID)
    mapping(address => mapping(uint256 => uint256)) public  childToParentTokenId; //Links each sequenced NFT to its parent RAW NFT token ID

    //ParentID => Child IDs
    mapping(uint256 => uint256[]) public tokenIDToParentTokenId; //Maps the token ID of parent to children token IDs

    //child ID => (parent ID => bool)
    mapping(uint256 => mapping(uint256 => bool)) public tokenIDToParentTokenIdCheck; //Checks if the provided token ID is a child to the parent ID

    //child ID => parent ID
    //mapping(uint256 => uint256) public childToParent;

    //parent ID => actively listed children id 
    mapping(uint256 => uint256) public ActiveChildrenListings; //This mapping is needed to check if the owner has any active listings before delisting the parent token





    // Full Access variables//

    //NFT count => request number
    mapping(uint256 => uint256) public FullAccessRequestNumberCounter;

    //NFT count => mapping(buyer address => request number)
    mapping(uint256 => mapping(address => uint256)) public FullAccessRequestNumberPerBuyer; 

    //NFT count => mapping (request number => buyer address)
    mapping(uint256 => mapping(uint256 => address)) public FullAccessBuyersAddress;

    //NFT count => mapping(buyer address => starting time)
    mapping(uint256 => mapping(address => uint256)) public FullAccessRequestStartingTime; //This is the time at which the request for full access was initiated by a buyer's address
   
    //mapping(uint256 => mapping(address => uint256)) public LimitedAccessRequestStartingTime; //This is the time at which the request for full access was initiated by a buyer's address

    // NFT count => mapping(buyer address => bool)
    //mapping(uint256 => mapping(address => bool)) public InitialFullAccessBuyers; //maps the nft id and buyer address to boolean
    // NFT count => mapping(buyer address => bool)
    mapping(uint256 => mapping(address => bool)) public FullAccessBuyersTracker; //maps the nft id and buyer address to boolean

    //NFTCount => mapping(reuqest number => bool)
    mapping(uint256 => mapping(uint256 => bool)) public FullAccessRequestCompleted; //Indicates if a request has been completed or not




    // NFT count => mapping(buyer address => bool)
    mapping(uint256 => mapping(address => bool)) public LimitedAccessBuyers; 

    //NFT count => mapping(buyer address => #operations)
    mapping(uint256 => mapping(address => uint256)) public LimitedAccessOperationsCounter; //Tracks the number of permitted limited access operations per buyer

    //**** Signature-Related Variables ****//

    struct SequencingSignature{
        address dataOwner;
        uint256 RawNFTId;
        IERC721 nft;
        uint256 tokenId;
        string message;
        bytes sig;
    }

    //NFT count => mapping(request number => struct);
    mapping(uint256 => mapping(uint256 => SequencingSignature)) public sequencingSignatures; //This mapping is for the signatures that confirm that the owner has received the sequenced data from the sequencing center


    struct InitialFullAccessSignature{
        address dataBuyer;
        uint256 SeqNFTId;
        IERC721 nft2;
        address dataOwner;
        uint256 tokenId;
        string message;
        bytes sig;
    }

    //NFT count => mapping(request number => struct);
    mapping(uint256 => mapping (uint256 => InitialFullAccessSignature)) public initialfullaccessSignatures; //This mapping is for the signatures that confirm that the buyer has received the sequenced data for the data owner


    struct FullAccessSignature{
        address dataBuyer;
        uint256 SeqNFTId;
        IERC721 nft2;
        uint256 tokenId;
        string message;
        bytes sig;
    }

    

    //NFT count => mapping(request number => struct);
    mapping(uint256 => mapping (uint256 => FullAccessSignature)) public fullaccessSignatures; //This mapping is for the signatures that confirm that the buyer has received the sequenced data for the data owner

    struct LimitedAccessSignature{
        address dataBuyer;
        uint256 SeqNFTId;
        IERC721 nft2;
        uint256 tokenId;
        string message;
        bytes sig;
    }

    //NFT count => mapping(request number => struct);
    mapping(uint256 => mapping(uint256 => LimitedAccessSignature)) public limitedaccessSignatures; //This mapping is for the signatures that confirm that the buyer has received the sequenced data for the data owner


    //**** Events ****//
    event ListedRawGenomicNFT(uint256 RawNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner);
    event DelistedRawGenomicNFT(uint256 RawNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner);
    event RawNFTSequencingPayment(uint256 RawNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address indexed buyer, uint256 requestnumber, uint256 sequencingStartTime, uint256 sequencingDeadline, uint256 sequencingmethod, uint256 sequencingcost);
    event SequencingCenterCommitted(uint256 RawNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address indexed CommittedsequencingCenter);
    event RawNFTisSequenced(uint256 RawNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address buyer, address indexed sequencingCenter, bytes sig);
    event DirectSequencingPayment(address indexed dataOwner, uint256 sequencingStartTime, uint256 sequencingDeadline);
    event ListedSequencedGenomicNFT(uint256 SeqNFTId, address indexed nft2 , uint256 tokenId, address indexed dataOwner, uint256 fullaccessprice, uint256 limitedaccessprice); 
    event SequencingSignatureStorage(address indexed verifiedAddress, address indexed dataOwner, address indexed nft, uint256 tokenId, string message, bytes signature);
    event DelistedSequencedGenomicNFT(uint256 SeqNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner);
    event FullAccessRequested(uint256 SeqNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address indexed fullaccessbuyer);
    event FullAccessGranted(uint256 SeqNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address indexed dataBuyer);
    event InitialFullAccessGranted(uint256 RawNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address indexed dataBuyer);
    event FullAccessSignatureStorage(address indexed verifiedAddress, address indexed dataBuyer, address indexed nft, uint256 tokenId, string message, bytes signature);
    event InitialFullAccessSignatureStorage(address indexed verifiedAddress, address indexed dataBuyer, address indexed nft, uint256 tokenId, string message, bytes signature);
    event LimitedAccessSignatureStorage(address indexed verifiedAddress, address indexed dataBuyer, address indexed nft, uint256 tokenId, string message, bytes signature);
    event LimitedAccessGranted(uint256 SeqNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address indexed dataBuyer);





    constructor(uint256 _SequencingPeriod, uint256 _InitialFullAccessGrantingPeriod, uint256 _sequencingPrice1, uint256 _sequencingPrice2, uint256 _sequencingPrice3, uint256 _FullAccessGrantingPeriod, uint256 _LimitedAccessGrantingPeriod, address _rawNFTaddress, address _seqNFTAddress){
        
        SequencingPeriod = _SequencingPeriod * 1 days; //The period is arbitrarly chosens
        InitialFullAccessGrantingPeriod = _InitialFullAccessGrantingPeriod * 1 days; //The period is arbitrarly chosen
        FullAccessGrantingPeriod = _FullAccessGrantingPeriod * 1 days; //The period is arbitrarly chosen
        LimitedAccessGrantingPeriod = _LimitedAccessGrantingPeriod * 1 days; //The period is arbitrarly chosen
        SequencingMethodPrice[1] = _sequencingPrice1 * 1 ether;
        SequencingMethodPrice[2] = _sequencingPrice2 * 1 ether;
        SequencingMethodPrice[3] = _sequencingPrice3 * 1 ether;
        RegistrationAuthority = msg.sender; //The deployer of the smart contract is the registration authority
        RawNFTSmartContract = IERC721(_rawNFTaddress); //the smart contract address is casted in IERC721 to allow it to access its functionalities such as transfer
        SequencedNFTSmartContract = IERC721(_seqNFTAddress);
        childToParentAddress[_seqNFTAddress] = _rawNFTaddress; //Indicates that the RAW NFT smart contract is the parent for Sequenced NFT address
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

    //function UpdateSequencingPrice(uint256 _price) external onlySequencingCenter{
    //    sequencingPrice = _price * 1 ether;
    //}


    function UpdateSequencingMethodPrice(uint256 _method1price, uint256 _method2price, uint256 _method3price) external onlySequencingCenter{
        SequencingMethodPrice[1] = _method1price * 1 ether;
        SequencingMethodPrice[2] = _method2price * 1 ether;
        SequencingMethodPrice[3] = _method3price * 1 ether;
    }

    //This function is used to return the max value among the sequencing methods prices [Note: The input is specified to 3 numbers because there are only 3 sequencing methods in our solution]
    function max(uint256[3] memory numbers) internal pure returns (uint256) {
    require(numbers.length > 0); // throw an exception if the condition is not met
    uint256 maxNumber; // default 0, the lowest value of `uint256`

    for (uint256 i = 0; i < numbers.length; i++) {
        if (numbers[i] > maxNumber) {
            maxNumber = numbers[i];
        }
    }

    return maxNumber;
}

    //This function only lists the raw genomic NFT so that interested buyer can view it and decide to sequence it or not
    //This function won't work unless the user has an NFT with the specified token ID in the RawNFTSmartContract
    function listRawGenomicNFT(uint256 _tokenId) external payable nonReentrant{
        uint256 securitydeposit = max([SequencingMethodPrice[1],SequencingMethodPrice[2],SequencingMethodPrice[3]]); //This line gets the highest sequencing method price so that the owner pays it as security deposit
        require(msg.value == securitydeposit, "Not enough ether to cover the security deposit");

        RawNFTSmartContract.transferFrom(msg.sender, address(this), _tokenId); //Transfers the NFT from its owner to the smart contract 
        RawNFTsCount++; 
        RawNFTs[RawNFTsCount] = RawGenomicNFT (RawNFTsCount, RawNFTSmartContract, _tokenId, payable(msg.sender),  SequencingMethodPrice[1], SequencingMethodPrice[2], SequencingMethodPrice[3]);
        
        SecurityDepositValue[RawNFTsCount] = securitydeposit;
        payable(address(this)).call{value: securitydeposit};  

        emit ListedRawGenomicNFT(RawNFTsCount, address(RawNFTSmartContract), _tokenId, msg.sender); 
    }

    function delistRawGenomicNFT(uint256 _RawNFTId) external nonReentrant{
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(msg.sender == Raw.dataOwner, "Only the owner of the Raw Genomic NFT is allowed to delist it");
        require(ActiveSequencingRequests[Raw.RawNFTId] == 0, "There are active sequencing requestes, therefore, it cannot be delisted");
        require(ActiveChildrenListings[Raw.RawNFTId] == 0, "The NFT cannot be delisted as it has active children NFTs listed");
        require(ActiveInitialFullAccessRequests[Raw.RawNFTId] == 0, "The NFT cannot be delisted as it has an active intial full access request");       
        delete SecurityDepositValue[Raw.RawNFTId]; 
        delete RawNFTs[_RawNFTId]; //Removes all entries of the delisted NFT
        Raw.nft.transferFrom(address(this), msg.sender, Raw.tokenId);
        payable(msg.sender).transfer(SecurityDepositValue[Raw.RawNFTId]);

        emit DelistedRawGenomicNFT(Raw.RawNFTId, address(Raw.nft), Raw.tokenId, msg.sender);
    }

    //This function allows an interested buyer to pay for the sequencing of a raw genomic NFT and gain full access
    //The owner can decide to pay for sequencing and pay for it
    function PayForRawNFTSequencing(uint256 _sequencingmethod, uint256 _RawNFTId) external payable nonReentrant{
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(_RawNFTId > 0 && _RawNFTId <= RawNFTsCount, "The requested NFT doesn't exist");
        require(SequencingMethodPrice[_sequencingmethod] > 0, "The selected sequencing method does not exist"); //If free sequencinng is required in the solution, then a mapping to boolean will be needed
        require(msg.value == SequencingMethodPrice[_sequencingmethod], "Not enough ether to cover the sequencing cost or it exceeds the sequencing cost");
        require(!sequencingPayerTracker[msg.sender][Raw.RawNFTId], "This buyer has already submitted a sequencing request for this NFT");
        //require(msg.sender != Raw.dataOwner, "The owner of the NFT cannot execute this function"); 

        payable(address(this)).call{value: SequencingMethodPrice[_sequencingmethod]}; //The sequencing value remains in the smart contract until the sequencing is completed 
        sequencingRequesterPaidAmount[msg.sender][Raw.RawNFTId] =  SequencingMethodPrice[_sequencingmethod]; //This is needed to process the payment for the buyer later on and keep track of him/her
        sequencingPayerTracker[msg.sender][Raw.RawNFTId] = true; //Tells if the msg.sender is an active sequencing payer or not
        SequencingRequestsCounter[Raw.RawNFTId] +=1; 
        SequencingRequestNumberPerBuyer[Raw.RawNFTId][msg.sender] = SequencingRequestsCounter[Raw.RawNFTId]; //Storing the request number per buyer
        ActiveSequencingRequests[Raw.RawNFTId] += 1; //The active number of requests can be updated when a request is fulfilled
        ActiveInitialFullAccessRequests[Raw.RawNFTId] += 1; //This is important to ensure the buyer receives the sequenced NFT from the buyer after the sequencing center finishes its task
        SequencingRequestStartTime[Raw.RawNFTId][SequencingRequestNumberPerBuyer[Raw.RawNFTId][msg.sender]] = block.timestamp; 
        SequenceRequesterAddress[Raw.RawNFTId][SequencingRequestsCounter[Raw.RawNFTId]] = msg.sender; //Stores the address of sequence requester to be used for checking during message signature
        RequestedSequencingMethod[Raw.RawNFTId][SequencingRequestNumberPerBuyer[Raw.RawNFTId][msg.sender]] = _sequencingmethod;
        SequencingRequestNumberExist[Raw.RawNFTId][SequencingRequestsCounter[Raw.RawNFTId]] = true; //This ensures that the sequence center selects a valid request number
        //NOTE: It is necessary to update the sequencing price of the requestd method in the struct of the NFT to ensure that the value
        // of the price is stored even if it is updated in the smart contract later on 
        if(_sequencingmethod == 1){
            Raw.sequencingcost1 = SequencingMethodPrice[_sequencingmethod];
        } else if(_sequencingmethod == 2){
            Raw.sequencingcost2 = SequencingMethodPrice[_sequencingmethod]; 
        } else if(_sequencingmethod == 3){
            Raw.sequencingcost3 = SequencingMethodPrice[_sequencingmethod];
        }
        
    
        emit RawNFTSequencingPayment(Raw.RawNFTId, address(Raw.nft), Raw.tokenId, Raw.dataOwner, msg.sender, SequencingRequestNumberPerBuyer[Raw.RawNFTId][msg.sender],  block.timestamp, block.timestamp+SequencingPeriod, _sequencingmethod, SequencingMethodPrice[_sequencingmethod]);

    }

    //This function allows a buyer to withdraw funds if the sequencing center does not sequence the genomic data in time
    function refundRawNFTSequencingPayment(uint256 _RawNFTId, uint256 _requestnumber) external payable nonReentrant{
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(SequenceRequesterAddress[Raw.RawNFTId][_requestnumber] == msg.sender, "The caller has not paid for the sequencing of this NFT");
        require(sequencingPayerTracker[msg.sender][Raw.RawNFTId], "The caller has not paid for the sequencing of this NFT"); 
        //require(SequencingRequestStartTime[Raw.RawNFTId][_requestnumber] > block.timestamp, "The time window for full access request is still openned");
        require(block.timestamp > SequencingRequestStartTime[Raw.RawNFTId][_requestnumber] + SequencingPeriod , "The time window for sequencing is still openned");
        require(!SequencingRequestCompleted[Raw.RawNFTId][_requestnumber], "This sequencing request has already been completed and funds cannot be withdrawn");
    
        //payable(msg.sender).call{value: sequencingRequesterPaidAmount[msg.sender][Raw.RawNFTId]}; 
        payable(msg.sender).transfer(sequencingRequesterPaidAmount[msg.sender][Raw.RawNFTId]);
        //SecurityDepositValue[Raw.RawNFTId] -= sequencingRequesterPaidAmount[msg.sender][Raw.RawNFTId]; //The paid amount by the buyer is deducted from the owner's security deposit
        sequencingPayerTracker[msg.sender][Raw.RawNFTId] = false;
        ActiveSequencingRequests[Raw.RawNFTId] -= 1; 
    }

        //This function allows a buyer to withdraw funds if the owner does not grant access to PRE in time
    function refundInitialFullAccessPayment(uint256 _RawNFTId, uint256 _requestnumber) external payable nonReentrant{
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(SequenceRequesterAddress[Raw.RawNFTId][_requestnumber] == msg.sender, "The caller has not paid for the sequencing of this NFT");
        require(sequencingPayerTracker[msg.sender][Raw.RawNFTId], "The caller has not paid for the sequencing of this NFT"); 
        require(block.timestamp > SequencingRequestStartTime[Raw.RawNFTId][_requestnumber] + SequencingPeriod + InitialFullAccessGrantingPeriod, "The time window for initial full access is still openned");
    
        SecurityDepositValue[Raw.RawNFTId] -= sequencingRequesterPaidAmount[msg.sender][Raw.RawNFTId]; //The paid amount by the buyer is deducted from the owner's security deposit
        payable(msg.sender).transfer(sequencingRequesterPaidAmount[msg.sender][Raw.RawNFTId]);

        ActiveInitialFullAccessRequests[Raw.RawNFTId] -= 0; //This allows the owner to withdraw the remaining security deposit from the delist function
    }

    //This function allows sequencing centers to commit to a raw genomic data sequencing
    function CommitToRawNFTSequencingRequest(uint256 _requestnumber, uint256 _RawNFTId) external onlySequencingCenter{
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(!SequencingRequestCompleted[Raw.RawNFTId][_requestnumber], "This sequencing request has already been completed");
        require(SequencingRequestNumberExist[Raw.RawNFTId][_requestnumber], "Either the inserted request number or NFT ID is invalid");
        require(CommittedsequencingCenter[Raw.RawNFTId][_requestnumber] == address(0), "A sequencing center is already committed to sequencing this raw genomic data");
        require(_RawNFTId > 0 && _RawNFTId <= RawNFTsCount, "The requested NFT doesn't exist");

        CommittedsequencingCenter[Raw.RawNFTId][_requestnumber] = payable(msg.sender); //The sequencing center calling this function becomes accountable for this NFT
        
        emit SequencingCenterCommitted(Raw.RawNFTId, address(Raw.nft),  Raw.tokenId,  Raw.dataOwner, msg.sender);


    }


    //Note: The delivery of DNA sample and returning the sequenced genomic data can be traced on-chain, but they are outside the scope of our paper
    //In the diagram, show that the original owner will receive data + minting allowance, whereas the buyer will only receive sequenced data
    function ConfirmRawNFTSequencing(uint256 _requestnumber, uint256 _RawNFTId) external payable nonReentrant onlySequencingCenter{
        
        SequencingSignature storage signature = sequencingSignatures[_RawNFTId][_requestnumber];
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(block.timestamp <= SequencingRequestStartTime[Raw.RawNFTId][_requestnumber] + SequencingPeriod, "The sequencing time window is already closed");
        require(CommittedsequencingCenter[Raw.RawNFTId][_requestnumber] == msg.sender, "Only the committed sequencing center to this NFT can execute this function");
        require(signature.dataOwner == Raw.dataOwner, "The sequencing center cannot prove sequencing raw genomic data without the reception confirmation signature of the owner");

        //payable(msg.sender).call{value: SequencingMethodPrice[RequestedSequencingMethod[Raw.RawNFTId][_requestnumber]]}; //Transfer the sequencing value to the sequencing center 
        payable(msg.sender).transfer(SequencingMethodPrice[RequestedSequencingMethod[Raw.RawNFTId][_requestnumber]]);
        ActiveSequencingRequests[Raw.RawNFTId] -= 1; 
        SequencingRequestCompleted[Raw.RawNFTId][_requestnumber] = true; 
        emit RawNFTisSequenced(Raw.RawNFTId, address(Raw.nft), Raw.tokenId, Raw.dataOwner, SequenceRequesterAddress[Raw.RawNFTId][_requestnumber], msg.sender, signature.sig);


    }


    //This function allows the original owner to withdraw the security deposit
    function InitialFullAccessProof(uint256 _RawNFTId, uint256 _requestnumber) external payable nonReentrant{
    RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
    InitialFullAccessSignature storage signature = initialfullaccessSignatures[Raw.RawNFTId][ _requestnumber];

    require(SequenceRequesterAddress[Raw.RawNFTId][_requestnumber] == signature.dataBuyer, "The signature does not belong to the sequencing buyer");
    require(sequencingPayerTracker[SequenceRequesterAddress[Raw.RawNFTId][_requestnumber]][Raw.RawNFTId], "The buyer address doesn't belong to any valid initial full access buyers");
    require(block.timestamp <= SequencingRequestStartTime[Raw.RawNFTId][_requestnumber] + SequencingPeriod + InitialFullAccessGrantingPeriod, "The Initial Full Access Granting Period time window is already closed");
    require(msg.sender == Raw.dataOwner, "Only the owner of the Raw NFT is allowed to run this function");

    ActiveInitialFullAccessRequests[Raw.RawNFTId] -= 1; //This allows the owner to delist the NFT 
    SequencedNFTMintingBalance[Raw.dataOwner][Raw.RawNFTId] += 1; //The data owner's balance/allowance of minting sequenced genomic data NFT that will be linked to this RAW NFT is increased by 1
    payable(msg.sender).transfer(SecurityDepositValue[Raw.RawNFTId]); //The data owner withdraws the security deposit after proving granting access to the buyer
    SecurityDepositValue[Raw.RawNFTId] = 0; //To prevent double spending if the owner delists the NFT later on
    
    emit InitialFullAccessGranted(Raw.RawNFTId, address(Raw.nft), Raw.tokenId, msg.sender, signature.dataBuyer);

    }

    //Should there be a function for the buyer to withdraw funds from the security deposit if the owner does not grant PRE access?



    //
    function LinkChildNFTtoParentNFT(uint256 _parentID, uint256 _childID) external onlySequencedNFTSC{
        RawGenomicNFT storage Raw = RawNFTs[_parentID]; //Stores all the related data of the requested genomic NFT to easily access it

        require(childToParentAddress[msg.sender] == address(RawNFTSmartContract), "Cannot link the new minted NFT as it is not a child of the parent NFT");
        
        childToParentTokenId[msg.sender][_childID] = Raw.tokenId; //Might not be needed
        tokenIDToParentTokenId[Raw.tokenId].push(_childID); //links the newly minted Child Id to its parent
        tokenIDToParentTokenIdCheck[_childID][Raw.tokenId] = true; //Used to verify that a certain child token ID actually belongs to a parent token ID(or the other way around)
    }

    //This function is accessed by the Sequenced NFT smart contract to update the balance of the owner after a successful sequenced NFT mint
    function UpdateSequencedNFTMintingBalance (address _dataOwner, uint256 _RawNFTId) external onlySequencedNFTSC{
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        SequencedNFTMintingBalance[_dataOwner][Raw.RawNFTId] -= 1;
    }


    //This function only lists the sequenced genomic NFT 
    //This function won't work unless the user has an NFT with the specified token ID in the SequencedNFTSmartContract
    function listSequencedGenomicNFT(uint256 _tokenId, uint256 _fullaccessprice, uint256 _limitedaccessprice) external nonReentrant{
        SequencedNFTSmartContract.transferFrom(msg.sender, address(this), _tokenId); //Transfers the NFT from its owner to the smart contract until process is completed
        SequencedNFTsCount++; 
        SequencedNFTs[SequencedNFTsCount] = SequencedGenomicNFT(SequencedNFTsCount, SequencedNFTSmartContract, payable(msg.sender), _tokenId, (_fullaccessprice * 1 ether),( _limitedaccessprice * 1 ether)); //new address[](0) is used to initialize an empty array
        ActiveChildrenListings[childToParentTokenId[address(SequencedNFTSmartContract)][_tokenId]] += 1;
        emit ListedSequencedGenomicNFT(SequencedNFTsCount, address(SequencedNFTSmartContract), _tokenId, msg.sender, _fullaccessprice, _limitedaccessprice); 
    }

    function delistSequencedGenomicNFT(uint256 _SeqNFTId) external nonReentrant{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(msg.sender == Sequenced.dataOwner, "Only the owner of the sequenced Genomic NFT is allowed to delist it");
        require(ActiveSequencedNFTAccessRequests[Sequenced.SeqNFTId] == 0, "Cannot delist while there are pending full/limited access requests");
        ActiveChildrenListings[Sequenced.SeqNFTId] -= 1;
        delete SequencedNFTs[Sequenced.SeqNFTId]; //Removes all entries of the delisted NFT
        Sequenced.nft2.transferFrom(address(this), msg.sender, Sequenced.tokenId);
        emit DelistedSequencedGenomicNFT(Sequenced.SeqNFTId, address(Sequenced.nft2), Sequenced.tokenId, msg.sender);
    }

    //When this function is executed, the NFT owner will have to enable the buyer to decrypt the encrypted symmetric key (K) with the buyer's private key by using PRE, which allows the buyer to decrypt the genomic data stored on IPFS using decrypted key "K"
    function requestFullAccess(uint256 _SeqNFTId) external payable nonReentrant{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(_SeqNFTId > 0 && _SeqNFTId <= SequencedNFTsCount , "The requested NFT does not exist");
        require(msg.value == Sequenced.fullaccessprice, "Not enough ether to cover the cost of full access");
        require(msg.sender != Sequenced.dataOwner, "The NFT owner cannot execute this function");
        require(!FullAccessBuyersTracker[Sequenced.SeqNFTId][msg.sender], "A request for full access for this NFT has already been made by this caller");

        payable(address(this)).call{value: Sequenced.fullaccessprice}; //The value of full access remains in the contract until the owner confirms sending it
        FullAccessRequestNumberCounter[Sequenced.SeqNFTId] += 1; //Tracks the current number of requests
        FullAccessRequestNumberPerBuyer[Sequenced.SeqNFTId][msg.sender] =  FullAccessRequestNumberCounter[Sequenced.SeqNFTId]; //Stores the request number for the buyer
        FullAccessBuyersAddress[Sequenced.SeqNFTId][FullAccessRequestNumberCounter[Sequenced.SeqNFTId]] = msg.sender; //Stores the address of the buyer for this request
        FullAccessBuyersTracker[Sequenced.SeqNFTId][msg.sender] = true; //Checks if the address of the buyer has requested full access
        ActiveSequencedNFTAccessRequests[Sequenced.SeqNFTId] += 1;
        FullAccessRequestStartingTime[Sequenced.SeqNFTId][msg.sender] = block.timestamp; 
        emit FullAccessRequested(Sequenced.SeqNFTId, address(Sequenced.nft2), Sequenced.tokenId, Sequenced.dataOwner, msg.sender);

    }

    //This function allows a buyer to withdraw funds if full access is not granted in time
    function withdrawFullAccessPayment(uint256 _SeqNFTId, uint256 _requestnumber) external payable nonReentrant{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(FullAccessBuyersAddress[Sequenced.SeqNFTId][_requestnumber] == msg.sender, "The request number doesn't belong to the caller");
        require(FullAccessBuyersTracker[Sequenced.SeqNFTId][msg.sender], "The caller has not paid for full access payment");
        require(FullAccessRequestStartingTime[Sequenced.SeqNFTId][msg.sender] > block.timestamp, "The time window for full access request is still openned");
        require(!FullAccessRequestCompleted[Sequenced.SeqNFTId][_requestnumber], "The full access request has already been completed and the payment cannot be withdrawn");

        payable(msg.sender).transfer(Sequenced.fullaccessprice); 
        FullAccessBuyersTracker[_SeqNFTId][msg.sender] = false;
        ActiveSequencedNFTAccessRequests[Sequenced.SeqNFTId] -= 1;
    }


    function ProofofFullAccess(uint256 _SeqNFTId, uint256 _requestnumber) external payable nonReentrant{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        FullAccessSignature storage signature = fullaccessSignatures[Sequenced.SeqNFTId][_requestnumber];

        require(FullAccessBuyersAddress[Sequenced.SeqNFTId][_requestnumber] == signature.dataBuyer, "The signature does not belong to the full access buyer");
        require(block.timestamp <= FullAccessRequestStartingTime[Sequenced.SeqNFTId][signature.dataBuyer] + FullAccessGrantingPeriod, "The full time access window for this buyer has already closed");
        require(msg.sender == Sequenced.dataOwner, "Only the owner of the Sequenced NFT is allowed to run this function");

        payable(msg.sender).transfer(Sequenced.fullaccessprice); //The value of the full access is transferred to the owner
        ActiveSequencedNFTAccessRequests[Sequenced.SeqNFTId] -= 1;
        FullAccessRequestCompleted[Sequenced.SeqNFTId][_requestnumber] = true; 


        emit FullAccessGranted(Sequenced.SeqNFTId, address(Sequenced.nft2), Sequenced.tokenId, msg.sender, signature.dataBuyer);

    }



    //This function increases the number of operations the buyer is allowed to perform homomorphically on the encrypted genomic data
    //It is assumed that once the buyer pays for operations, he's allowed to perform operations homomorphically on the data immediatly, therefore, there is no need for ProofofLimitedAccess Function
    function requestLimitedAccess(uint256 _SeqNFTId, uint256 _numberofoperations) external payable nonReentrant{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(_SeqNFTId > 0 && _SeqNFTId <= SequencedNFTsCount , "The requested NFT does not exist");
        require(msg.value == _numberofoperations * Sequenced.limitedaccessprice, "Not enough ether to cover the cost of limited access");
        require(msg.sender != Sequenced.dataOwner, "The NFT owner cannot execute this function");

        //LimitedAccessRequestStartingTime[_SeqNFTId][msg.sender] = block.timestamp;
        LimitedAccessOperationsCounter[_SeqNFTId][msg.sender] +=  _numberofoperations; //The number of permitted operations for the msg.sender for this specific NFT (_SeqNFTId) is increased
        payable(Sequenced.dataOwner).transfer(_numberofoperations * Sequenced.limitedaccessprice); //The total value should be the requested number of operations * cost/operation

    }


    function UpdateBuyerLimitedAccessOperations(uint256 _SeqNFTId, uint256 _numberofexecutedoperations, address _dataBuyer) external onlyLimitedAccessOracle{
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        
        LimitedAccessOperationsCounter[Sequenced.SeqNFTId][_dataBuyer] -= _numberofexecutedoperations; // This updates the balance of operations for the limited access buyer

    }










    //**** Singature Functions ****//

    //Signatures Storage is needed to verify the data owner has received the sequenced data from the sequencing center
    function storeSequencingSignatures(string memory message, bytes memory sig, uint256 _RawNFTId, uint256 _requestnumber) public {
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId];        
        require(isValidSignature(message,sig) == Raw.dataOwner, "Invalid signature"); //if they match then it confirms the receiver is the data owner
        require(!SequencingRequestCompleted[Raw.RawNFTId][_requestnumber], "This request has already been fulfilled");


        sequencingSignatures[_RawNFTId][_requestnumber] = SequencingSignature (Raw.dataOwner, Raw.RawNFTId, Raw.nft, Raw.tokenId, message, sig);

        emit SequencingSignatureStorage(isValidSignature(message,sig), Raw.dataOwner, address(Raw.nft),  Raw.tokenId,  message,  sig);
    }

        //Signatures storage is needed to verify the data buyer has received the sequenced data from the data owner (Initial sequencing payment)
    function storeInitialFullAccessSignatures(string memory message, bytes memory sig, uint256 _RawNFTId, address _signer, uint256 _requestnumber) public {
        RawGenomicNFT storage Raw = RawNFTs[_RawNFTId];        
        require(SequenceRequesterAddress[Raw.RawNFTId][_requestnumber] == _signer, "The inserted signer address does not belong to a valid buyer");
        //require(!SequencingRequestCompleted[Raw.RawNFTId][_requestnumber], "This request has already been fulfilled");
        require(isValidSignature(message, sig) == _signer, "Invalid signature");

        initialfullaccessSignatures[Raw.RawNFTId][ _requestnumber] = InitialFullAccessSignature(_signer, Raw.RawNFTId, Raw.nft, Raw.dataOwner, Raw.tokenId, message, sig);

        emit InitialFullAccessSignatureStorage(isValidSignature(message, sig), _signer, address(Raw.nft),  Raw.tokenId,  message,  sig);
    }

    //Signatures storage is needed to verify the data buyer has received the sequenced data from the data owner
    function storeFullAccessSignatures(string memory message,  bytes memory sig, uint256 _SeqNFTId, address _signer, uint256 _requestnumber) public {
        SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(FullAccessBuyersAddress[Sequenced.SeqNFTId][_requestnumber] == _signer, "The input signer address does not belong to a valid buyer or a valid request number");
        require(!FullAccessRequestCompleted[Sequenced.SeqNFTId][_requestnumber], "This request has already been fulfilled");
        require(isValidSignature(message, sig) == _signer, "Invalid signature");

        fullaccessSignatures[Sequenced.SeqNFTId][_requestnumber] = FullAccessSignature(_signer, Sequenced.SeqNFTId, Sequenced.nft2, Sequenced.tokenId, message, sig);

        emit FullAccessSignatureStorage(isValidSignature(message, sig), _signer, address(Sequenced.nft2),  Sequenced.tokenId,  message,  sig);
    }

        //Signatures storage is needed to verify the data buyer has received the sequenced data from the data owner
    //function storeLimitedAccessSignatures(string memory message, uint8 v, bytes32 r, bytes32 s, bytes memory sig, uint256 _SeqNFTId, address _signer, uint256 _requestnumber) public {
    //    SequencedGenomicNFT storage Sequenced = SequencedNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
    //   require(LimitedAccessBuyers[_SeqNFTId][_signer], "The input signer address must belong to one of the active Limited access buyers");
    //    require(isValidSignature(message, v, r, s) == _signer, "Invalid signature");

    //   limitedaccessSignatures[_SeqNFTId][_requestnumber] = LimitedAccessSignature(_signer, Sequenced.SeqNFTId, Sequenced.nft2, Sequenced.tokenId, message, sig);

    //    emit LimitedAccessSignatureStorage(isValidSignature(message, v, r, s), _signer, address(Sequenced.nft2),  Sequenced.tokenId,  message,  sig);
    //}
    

    // Returns the public address that signed a given string message (Message Signing)
    function isValidSignature(string memory message, bytes memory sig) public pure returns (address signer) {

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
        r := mload(add(sig, 32))
        s := mload(add(sig, 64))
        v := and(mload(add(sig, 65)), 255)
        }
        
        if (v < 27) v += 27;

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
