const { hexConcat } = require("ethers/lib/utils");

const main = async () => {
    const [guy, randomGuy, attacker] = await hre.ethers.getSigners();
    const ethwei = hre.ethers.utils;

    const nftContractFactory = await hre.ethers.getContractFactory("testNFT");
    const nftContract = await nftContractFactory.deploy();

    const marketContractFactory = await hre.ethers.getContractFactory("NFTMarket");
    const marketContract = await marketContractFactory.deploy();

    const mintNFT = await nftContract.mint();
    await mintNFT.wait();

    const _mintNFT = await nftContract.mint();
    await _mintNFT.wait();

    const _approve = await nftContract.setApprovalForAll(marketContract.address, true);
    const _list = await marketContract.listNFT(nftContract.address, 1, hre.ethers.utils.parseEther('1'));

    const _0status = await marketContract.getListStatus(nftContract.address, 0);
    console.log("NFT#0 listed status:", _0status);
    console.log("Price of #0:", await marketContract.getListPrice(nftContract.address, 0));
    console.log("Price of #1:", await marketContract.getListPrice(nftContract.address, 1));

    const _0ow = await marketContract.getNFTOwner(nftContract.address, 0);
    console.log("NFT#0's owner is", _0ow);

    const _1ow = await marketContract.getNFTOwner(nftContract.address, 1);
    console.log("NFT#1's owner is", _1ow);

    const _1status = await marketContract.getListStatus(nftContract.address, 1);
    console.log("NFT#1 listed status:", _1status);

    const _buy = await marketContract.connect(randomGuy).buyNFT(nftContract.address, 1, {value: hre.ethers.utils.parseEther('1')});
    const _1own = await marketContract.getNFTOwner(nftContract.address, 1);
    console.log("NFT#1's owner is", _1own);

    console.log(hre.ethers.utils.formatEther(await hre.ethers.provider.getBalance(guy.address)));
    console.log(hre.ethers.utils.formatEther(await hre.ethers.provider.getBalance(randomGuy.address)));

    const _2 = await nftContract.connect(randomGuy).mint();
    const _2apv = await nftContract.connect(randomGuy).setApprovalForAll(marketContract.address, true);
    const _2l = await marketContract.connect(randomGuy).listNFT(nftContract.address, 2, hre.ethers.utils.parseEther('0.01'));

    const _detail = await marketContract.getNFTsDetail(nftContract.address, 3);
    console.log(_detail);

    const __mintNFT = await nftContract.mint();
    await __mintNFT.wait();

    const chainId = await guy.getChainId(); // 1337
    console.log('Chain ID:', chainId);
    const nonce = 0;
    const name = "Gold";
    const version = "1";
    const token = "0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1";
    const spender = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
    const value = 1000;
    const deadline = 100;

    const abi = ethers.utils.defaultAbiCoder;

    const _PERMIT_TYPEHASH = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(
        "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"));

    const structHash = ethers.utils.keccak256(abi.encode(
        ["bytes32", "address", "address", "uint256", "uint256", "uint256"],
        [_PERMIT_TYPEHASH, guy.address, spender, value, nonce, deadline]));

    const typeHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"));
    const nameHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(name));
    const versionHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(version));
    const domainSeparator = ethers.utils.keccak256(abi.encode(
        ["bytes32", "bytes32", "bytes32", "uint256", "address"],
        [typeHash, nameHash, versionHash, chainId, token]
    ));

    const typedDataHash = ethers.utils.keccak256(ethers.utils.solidityPack(
        ["string", "bytes32", "bytes32"],
        ["\x19\x01", domainSeparator, structHash]));

    const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"; // 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    const signingKey = new ethers.utils.SigningKey(privateKey); // without prefix "\x19Ethereum Signed Message:\n32"

    const signature = await signingKey.signDigest(typedDataHash);

    const __list = await marketContract.listNFT(nftContract.address, 3, ethwei.parseEther('1'));
    console.log('listed, price: ', await marketContract.getListPrice(nftContract.address, 3));
    const _updatelist = await marketContract.updatePrice(nftContract.address, 3, ethwei.parseEther('10'))
    console.log('updated, price:', await marketContract.getListPrice(nftContract.address, 3));
    const _buy_ = await marketContract.connect(randomGuy).buyNFT(nftContract.address, 3, {value: ethwei.parseEther('100')});
    console.log('bought, owner of #3:', await nftContract.ownerOf(3));
}

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    }
    catch(error) {
        console.log(error);
        process.exit(1);
    }
}

runMain();