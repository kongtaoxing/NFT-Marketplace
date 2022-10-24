//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

interface NFTContract {
    //basic NFT function
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function ownerOf(uint256 _tokenId) external view returns (address);

    //Get NFT's detail
    function name() external view returns (string calldata _name);
    function symbol() external view returns (string calldata _symbol);
    function tokenURI(uint256 _tokenId) external view returns (string calldata);
    function totalSupply() external view returns(uint256);
}

contract NFTMarket {

    address owner;

    error notApproved();
    error notOwner();
    error insufficientBalance();
    error notListed();

    struct NFTDetail {
        string _name;
        string _symbol;
        string _tokenURI;
    }
    
    mapping(address => mapping(uint256 => bool)) _listStatus;
    mapping(address => mapping(uint256 => uint256)) _listedPrice;
    mapping(address => mapping(uint256 => address)) _isOwner;

    constructor() {
        console.log("NFTMarket deployed");
        owner = msg.sender;
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

    function signToListNFT(address _NFTContract, uint256 _tokenId, uint256 _price) public {
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

    function getNFTOwner(address _NFTContract, uint256 _tokenId) public view returns(address) {
        return _isOwner[_NFTContract][_tokenId];
    }

    function buyNFT(address _NFTContract, uint256 _tokenId) public payable {
        if(msg.value < _listedPrice[_NFTContract][_tokenId]) {
            revert insufficientBalance();
        }
        if(!_listStatus[_NFTContract][_tokenId]) {
            revert notListed();
        }
        payable(_isOwner[_NFTContract][_tokenId]).transfer(msg.value * 9 / 10);
        NFTContract(_NFTContract).transferFrom(_isOwner[_NFTContract][_tokenId], msg.sender, _tokenId);
        _listStatus[_NFTContract][_tokenId] = false;
        _isOwner[_NFTContract][_tokenId] = address(0);
        _listedPrice[_NFTContract][_tokenId] = 0;
    }

    function getNFTsDetail(address _NFTContract, uint256 _amounts) public view returns (NFTDetail[] memory) {
        //uint256 _amounts = NFTContract(_NFTContract).totalSupply();
        NFTDetail[] memory _detail = new NFTDetail[](_amounts);
        for (uint256 i = 0; i < _amounts; i++) {
            _detail[i]._name = NFTContract(_NFTContract).name();
            _detail[i]._symbol = NFTContract(_NFTContract).symbol();
            _detail[i]._tokenURI = NFTContract(_NFTContract).tokenURI(i);
        }
        return _detail;
    }

    function withdraw() onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getContractOwner() public view returns (address) {
        return owner;
    }

    function changeOwner(address _newOwner) onlyOwner public {
        owner = _newOwner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert notOwner();
        }
        _;
    }
}