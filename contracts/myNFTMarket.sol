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
    string version = "1.0";
    string name = "NFTMarket";   //contract name 
    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("ListNFTwithSig(address _NFTContract,uint256 _tokenId,uint256 _price,uint256 nonce,uint256 deadline)")
    bytes32 public constant LIST_TYPEHASH = 0x6f8a295cea3edab22428a30506be6fb57d93dd2ba58973d57bb71c48af8fbc7e;

    error notApproved();
    error notOwner();
    error insufficientBalance();
    error notListed();
    error mustBiggerThanZero();
    error invalidSigLen();

    struct NFTDetail {
        string _name;
        string _symbol;
        string _tokenURI;
        bool _listOrNot;
        uint256 _price;
        address _owner;
    }
    
    mapping(address => mapping(uint256 => bool)) _listStatus;
    mapping(address => mapping(uint256 => uint256)) _listedPrice;
    mapping(address => mapping(uint256 => address)) _isOwner;
    mapping(address => uint) public nonces;// 记录合约中每个地址使用链下签名消息交易的数量，用来防止重放攻击。

    //Add events
    event ListNFT(address indexed NFTContract, uint256 indexed tokenId, uint256 indexed price);
    event UpdatePrice(address indexed NFTContract, uint256 indexed tokenId, uint256 indexed newPrice);
    event DelistNFT(address indexed NFTContract, uint256 indexed tokenId);
    event BuyNFT(address indexed buyer, address indexed NFTContract, uint256 indexed tokenId);

    event ChangeOwner(address indexed newOwner);

    constructor() {
        console.log("NFTMarket deployed");
        owner = msg.sender;
        uint256 chainId;
        assembly {    //buildin assembly to get chainID
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name, string version, uint256 chainId, address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                address(this)
            )
        );
        // console.log("constructor chainId:", chainId);  //1337
    }

    function listNFT(address _NFTContract, uint256 _tokenId, uint256 _price) public {
        if(!NFTContract(_NFTContract).isApprovedForAll(msg.sender, address(this))) {
            revert notApproved();
        }
        if(NFTContract(_NFTContract).ownerOf(_tokenId) != msg.sender) {
            revert notOwner();
        }
        if (_price <= 0) revert mustBiggerThanZero();
        //NFTContract(_NFTContract).transferFrom(msg.sender, address(this), _tokenId);
        _listedPrice[_NFTContract][_tokenId] = _price;
        _listStatus[_NFTContract][_tokenId] = true;
        _isOwner[_NFTContract][_tokenId] = msg.sender;

        //emit event
        emit ListNFT(_NFTContract, _tokenId, _price);
    }

    function listNFTwithSig(address _NFTContract, uint256 _tokenId, uint256 _price, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        console.log('nonce:', nonces[owner]);
        console.log('_NFTContract:', _NFTContract);
        console.log('id:', _tokenId, 'price:', _price);
        console.log('deadline:', deadline);
        console.log('sig:', v);
        console.logBytes32(r);
        console.logBytes32(s);
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(LIST_TYPEHASH, _NFTContract, _tokenId, _price, nonces[owner]++, deadline))
                // 每调用一次`permit`，相应地址的 nonce 就会加 1，
                // 这样再使用原来的签名消息就无法再通过验证了（重建的签名消息不正确了），用于防止重放攻击。
            )
        );
        address ownerOfNFT = ecrecover(digest, v, r, s);  //获取消息签名者的地址
        console.log("Signer's address: ",ownerOfNFT);
        if(!NFTContract(_NFTContract).isApprovedForAll(ownerOfNFT, address(this))) {
            revert notApproved();
        }
        if(NFTContract(_NFTContract).ownerOf(_tokenId) != ownerOfNFT) {
            revert notOwner();
        }
        if (_price <= 0) revert mustBiggerThanZero();
        _listedPrice[_NFTContract][_tokenId] = _price;
        _listStatus[_NFTContract][_tokenId] = true;
        _isOwner[_NFTContract][_tokenId] = ownerOfNFT;

        //emit event
        emit ListNFT(_NFTContract, _tokenId, _price);
    }

    // function listNFTwithSig(address _NFTContract, uint256 _tokenId, uint256 _price, uint256 deadline, bytes memory _signature) public {
    //     // 检查签名长度，65是标准r,s,v签名的长度
    //     if(_signature.length != 65) revert invalidSigLen();
    //     bytes32 r;
    //     bytes32 s;
    //     uint8 v;
    //     // 目前只能用assembly (内联汇编)来从签名中获得r,s,v的值
    //     assembly {
    //         // 读取长度数据后的32 bytes
    //         r := mload(add(_signature, 0x20))
    //         // 读取之后的32 bytes
    //         s := mload(add(_signature, 0x40))
    //         // 读取最后一个byte
    //         v := byte(0, mload(add(_signature, 0x60)))
    //     }
    //     console.log('sig:', v);
    //     console.logBytes32(r);
    //     console.logBytes32(s);
    //     bytes32 digest = keccak256(
    //         abi.encodePacked(
    //             '\x19\x01',
    //             DOMAIN_SEPARATOR,
    //             keccak256(abi.encode(LIST_TYPEHASH, _NFTContract, _tokenId, _price, nonces[owner], deadline))
    //             // 每调用一次`permit`，相应地址的 nonce 就会加 1，
    //             // 这样再使用原来的签名消息就无法再通过验证了（重建的签名消息不正确了），用于防止重放攻击。
    //         )
    //     );
    //     address ownerOfNFT = ecrecover(digest, v, r, s);  //获取消息签名者的地址
    //     console.log("Signer's address: ",ownerOfNFT);
    //     if(!NFTContract(_NFTContract).isApprovedForAll(ownerOfNFT, address(this))) {
    //         revert notApproved();
    //     }
    //     if(NFTContract(_NFTContract).ownerOf(_tokenId) != ownerOfNFT) {
    //         revert notOwner();
    //     }
    //     if (_price <= 0) revert mustBiggerThanZero();
    //     _listedPrice[_NFTContract][_tokenId] = _price;
    //     _listStatus[_NFTContract][_tokenId] = true;
    //     _isOwner[_NFTContract][_tokenId] = ownerOfNFT;

    //     //emit event
    //     emit ListNFT(_NFTContract, _tokenId, _price);
    // }

    function updatePrice(address _NFTContract, uint256 _tokenId, uint256 _newPrice) public {
        if(!NFTContract(_NFTContract).isApprovedForAll(msg.sender, address(this))) {
            revert notApproved();
        }
        if(NFTContract(_NFTContract).ownerOf(_tokenId) != msg.sender) {
            revert notOwner();
        }
        if (_newPrice <= 0) revert mustBiggerThanZero();
        if (!_listStatus[_NFTContract][_tokenId]) revert notListed();
        _listedPrice[_NFTContract][_tokenId] = _newPrice;

        emit UpdatePrice(_NFTContract, _tokenId, _newPrice);
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

        emit DelistNFT(_NFTContract, _tokenId);
        
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
        payable(_isOwner[_NFTContract][_tokenId]).transfer(_listedPrice[_NFTContract][_tokenId] * 9 / 10);
        payable(msg.sender).transfer(msg.value - _listedPrice[_NFTContract][_tokenId]);   //退回多余的ETH
        NFTContract(_NFTContract).transferFrom(_isOwner[_NFTContract][_tokenId], msg.sender, _tokenId);
        _listStatus[_NFTContract][_tokenId] = false;
        _isOwner[_NFTContract][_tokenId] = address(0);
        _listedPrice[_NFTContract][_tokenId] = 0;

        emit BuyNFT(msg.sender, _NFTContract, _tokenId);
    }

    function buyNFTwithSig(address _NFTContract, uint256 _tokenId, uint8 v, bytes32 r, bytes32 s) public payable {
        //listNFTwithSig(_NFTContract, _tokenId, _price, deadline, v, r, s);
    }

    function getNFTsDetail(address _NFTContract, uint256 _amounts) public view returns (NFTDetail[] memory) {
        //uint256 _amounts = NFTContract(_NFTContract).totalSupply();
        NFTDetail[] memory _detail = new NFTDetail[](_amounts);
        for (uint256 i = 0; i < _amounts; i++) {
            _detail[i]._name = NFTContract(_NFTContract).name();
            _detail[i]._symbol = NFTContract(_NFTContract).symbol();
            _detail[i]._tokenURI = NFTContract(_NFTContract).tokenURI(i);
            _detail[i]._listOrNot = _listStatus[_NFTContract][i];
            _detail[i]._price = _listedPrice[_NFTContract][i];
            _detail[i]._owner = NFTContract(_NFTContract).ownerOf(i);
        }
        return _detail;
    }

    function getListedTokenId(address _NFTContract, uint256 _totalAmount) public view returns (uint256[] memory) {
        uint256 _listed = 0;
        for (uint256 i = 0; i < _totalAmount; i++) {
            if (_listStatus[_NFTContract][i] == true) {
                _listed++;
            } 
        }
        uint256[] memory _listedTokenId = new uint256[](_listed);
        uint256 flag = 0;
        for(uint256 i = 0; i < _totalAmount; i++) {
            if (_listStatus[_NFTContract][i] == true) {
                _listedTokenId[flag] = i;
                flag++;
            }
        }
        return _listedTokenId;
    }

    function withdraw() onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getContractOwner() public view returns (address) {
        return owner;
    }

    function changeOwner(address _newOwner) onlyOwner public {
        owner = _newOwner;

        emit ChangeOwner(_newOwner);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert notOwner();
        }
        _;
    }
}