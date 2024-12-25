// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract test is Ownable, ERC721URIStorage {
    address payable ownerAddress;
    uint256 platformFess = 0.02 ether;

    constructor() Ownable(msg.sender) ERC721("Owner", "Manav") {
        ownerAddress = payable(msg.sender);
    }

    function updateFees(uint256 _transactionFees)
        external
        onlyOwner
        returns (uint256)
    {
        require(_transactionFees > 0, "Platform Fee can't be zero");
        platformFess = _transactionFees;
        return platformFess;
    }

    function _chargeTransactionFees() internal virtual {
        require(msg.value >= platformFess, "Insufficient transaction fee");

        // Transfer fee to the recipient
        (bool sent, ) = ownerAddress.call{value: platformFess}("");
        require(sent, "Failed to transfer transaction fee");
    }

    // Ensure the contract can accept ETH
    receive() external payable {}
}