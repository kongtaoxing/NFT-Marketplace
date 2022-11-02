//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract testNFT is ERC721 {
    uint256 _tokenId;
    address payable owner;

    error notOwner();

    constructor() ERC721("testNFT", "tNFT") {
        owner = payable(msg.sender);
        console.log("NFT deployed");
    }

    function mint() public {
        _safeMint(msg.sender, _tokenId);
        console.log("NFT#", _tokenId, "has been minted");
        _tokenId++;
    }
}

contract test1155 is ERC1155 {
    constructor() ERC1155("test1155") {
        console.log("1155 deployed");
    }

    function mint() public {
        bytes memory data;
        _mint(msg.sender, 0, 100, data);
        console.log("100 ERC1155 minted to", msg.sender);
    }
}