//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "test.sol";

contract PicaxaNFTCollection is test {
    uint256 tokenCount;
    address owner;

    constructor() ERC721("Art By Manav", "Manav") {
        owner = msg.sender;
    }

    struct NFTBody {
        string name;
        uint256 price;
        string image;
        string description;
    }

    function mint(string memory tokenURI) external returns (uint256) {
        tokenCount++;
        _safeMint(msg.sender, tokenCount);
        _setTokenURI(tokenCount, tokenURI);
        return tokenCount;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        _chargeTransactionFees(); // Charge fee on transfer
        super.safeTransferFrom(from, to, tokenId);
    }
}