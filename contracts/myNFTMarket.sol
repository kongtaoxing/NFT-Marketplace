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
    error insufficientBalance();
    error notListed();
    
    mapping(address => mapping(uint256 => bool)) _listStatus;
    mapping(address => mapping(uint256 => uint256)) _listedPrice;
    mapping(address => mapping(uint256 => address)) _isOwner;

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
        //NFTContract(_NFTContract).transferFrom(msg.sender, address(this), _tokenId);
        _listedPrice[_NFTContract][_tokenId] = _price;
        _listStatus[_NFTContract][_tokenId] = true;
        _isOwner[_NFTContract][_tokenId] = msg.sender;
    }

    function delistNFT(address _NFTContract, uint256 _tokenId) public {
        if(_isOwner[_NFTContract][_tokenId] != msg.sender) {
            revert notOwner();
        }
        if(!_listStatus[_NFTContract][_tokenId]) {
            revert notListed();
        }
        //NFTContract(_NFTContract).transferFrom(address(this), msg.sender, _tokenId);
        _listStatus[_NFTContract][_tokenId] = false;
        _isOwner[_NFTContract][_tokenId] = address(0);
        _listedPrice[_NFTContract][_tokenId] = 0;
        
    }

    function getListStatus(address _NFTContract, uint256 _tokenId) public view returns (bool){
        return _listStatus[_NFTContract][_tokenId];
    }

    function getListPrice(address _NFTContract, uint256 _tokenId) public view returns (uint256) {
        return _listedPrice[_NFTContract][_tokenId];
    }

    function getOwner(address _NFTContract, uint256 _tokenId) public view returns(address) {
        return _isOwner[_NFTContract][_tokenId];
    }

    function buyNFT(address _NFTContract, uint256 _tokenId) public payable {
        if(msg.value < _listedPrice[_NFTContract][_tokenId]) {
            revert insufficientBalance();
        }
        if(!_listStatus[_NFTContract][_tokenId]) {
            revert notListed();
        }
        payable(_isOwner[_NFTContract][_tokenId]).transfer(msg.value);
        NFTContract(_NFTContract).transferFrom(_isOwner[_NFTContract][_tokenId], msg.sender, _tokenId);
        _listStatus[_NFTContract][_tokenId] = false;
        _isOwner[_NFTContract][_tokenId] = address(0);
        _listedPrice[_NFTContract][_tokenId] = 0;
    }
}