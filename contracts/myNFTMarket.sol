//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

interface NFTContract {
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function ownerOf(uint256 _tokenId) external view returns (address);
}


contract NFTMarket {

    error notApproved();
    error notOwner();

    struct NFTListed {
        bool isList;
        address _contract;
        address payable _owner;
        uint256 _price;
    }
    mapping(address => NFTListed) Status;
    mapping (uint256 => uint256) _listedPrice;

    constructor() {
        console.log("NFTMarket deployed");
    }

    function listNFT(address _NFTContract, uint256 _tokenId, uint256 _price) public {
        if(!NFTContract(_NFTContract).isApprovedForAll(msg.sender, address(this))) {
            revert notApproved();
        }
        if(NFTContract(_NFTContract).ownerOf(_tokenId) != msg.sender) {
            revert notOwner();
        }
        NFTContract(_NFTContract).transferFrom(msg.sender, address(this), _tokenId);

    }
}