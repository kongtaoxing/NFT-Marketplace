//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract testNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    address payable owner;

    error notOwner();

    constructor() ERC721("testNFT", "tNFT") {
        owner = payable(msg.sender);
        console.log("NFT deployed");
    }
}

contract NFTMarket {
    constructor() {
        console.log("NFTMarket deployed");
    }
}