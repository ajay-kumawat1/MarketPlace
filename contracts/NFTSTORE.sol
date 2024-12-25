// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTSTORE is ERC721URIStorage {
    address payable public marketplaceOwner;
    uint256 public listingFeePercent = 20;
    uint256 private currentTokenId;
    uint256 private totalItemsSold;

    struct NFTListing {
        uint256 tokenId;
        address owner;
        address payable seller;
        uint256 price;
    }

    mapping(uint256 => NFTListing) private tokenIdToListing;

    modifier onlyMarketplaceOwner() {
        require(msg.sender == marketplaceOwner, "Only marketplace owner can call this function");
        _;
    }

    constructor() ERC721("NFTSTORE", "NFT") {
        marketplaceOwner = payable(msg.sender); // the person who deploys the contract is the marketplace owner
    }

    // update the listing fee percent
    function updateListingFeePercent(uint256 _listingFeePercent) public onlyMarketplaceOwner {
        listingFeePercent = _listingFeePercent;
    }

    // get the listing fee percent
    function getListingFeePercent() public view returns (uint256) {
        return listingFeePercent;
    }

    // get current token id
    function getCurrentTokenId() public view returns (uint256) {
        return currentTokenId;
    }

    // get NFT listing by token id
    function getNFTListing(uint256 _tokenId) public view returns (NFTListing memory) {
        return tokenIdToListing[_tokenId];
    }

    // create a token or selling an NFT
    function createToken(string memory _tokenURI, uint256 _price) public returns (uint256) {
        require(_price > 0, "Price must be greater than 0");
        currentTokenId++;
        
        uint256 newTokenId = currentTokenId;
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        _createNFTListing(newTokenId, _price);
        return newTokenId;
    }

    function _createNFTListing(uint256 _tokenId, uint256 _price) private {
        tokenIdToListing[_tokenId] = NFTListing({
            tokenId: _tokenId,
            owner: payable(msg.sender),
            seller: payable(msg.sender),
            price: _price
        });
    }

    // execute sale function
    function executeSale(uint256 _tokenId) public payable {
        NFTListing memory listing = tokenIdToListing[_tokenId];
        require(msg.value >= listing.price, "Not enough ether sent");
        require(msg.sender != listing.owner, "Owner cannot buy their own NFT");

        uint256 price = listing.price;
        address payable seller = listing.seller;
        listing.seller = payable(msg.sender);
        totalItemsSold++;
        _transfer(listing.owner, msg.sender, _tokenId);

        uint256 listingFee = (price * listingFeePercent) / 100;
        marketplaceOwner.transfer(listingFee);
        seller.transfer(msg.value - listingFee);
    }

    // get all listed NFTs
    function getAllListedNFTs() public view returns (NFTListing[] memory) {
        // total nft count
        uint256 totalNFTCount = currentTokenId;
        NFTListing[] memory listedNFTs = new NFTListing[](totalNFTCount);
        uint256 currentIndex = 0;

        for(uint256 i = 0; i <= totalNFTCount; i++) {
            uint tokenId = i+1;
            NFTListing memory listing = tokenIdToListing[tokenId];
            listedNFTs[currentIndex] = listing;
            currentIndex += 1;
        }
        return listedNFTs;
    }

    // get my listed NFTs
    function getMyListedNFTs() public view returns (NFTListing[] memory) {
        // My NFT count
        uint256 totalNFTCount = currentTokenId;
        uint myNFTCount = 0;
        uint256 currentIndex = 0;

        for(uint256 i = 0; i <= totalNFTCount; i++) {
            if(tokenIdToListing[i+1].owner == msg.sender || tokenIdToListing[i+1].seller == msg.sender) {
                myNFTCount++;
            }
        }

        NFTListing[] memory myNFTs = new NFTListing[](myNFTCount);
        for(uint256 i = 0; i <= totalNFTCount; i++) {
            if(tokenIdToListing[i+1].owner == msg.sender || tokenIdToListing[i+1].seller == msg.sender) {
                uint tokenId = i+1;
                NFTListing storage listing = tokenIdToListing[tokenId];
                myNFTs[currentIndex] = listing;
                currentIndex += 1;
            }
        }
        return myNFTs;

    }
}