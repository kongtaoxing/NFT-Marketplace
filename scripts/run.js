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

    const __list = await marketContract.listNFT(nftContract.address, 3, ethwei.parseEther('1'));
    console.log('listed, price: ', await marketContract.getListPrice(nftContract.address, 3));
    const _updatelist = await marketContract.updatePrice(nftContract.address, 3, ethwei.parseEther('10'))
    console.log('updated, price:', await marketContract.getListPrice(nftContract.address, 3));
    const _buy_ = await marketContract.connect(randomGuy).buyNFT(nftContract.address, 3, {value: ethwei.parseEther('100')});
    console.log('bought, owner of #3:', await nftContract.ownerOf(3));

    const _mintNFT__ = await nftContract.mint();
    await _mintNFT__.wait();

    const chainId = await guy.getChainId(); // 1337
    const nonce = 0;
    const name = "Gold";
    const version = "1";
    const token = "0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1";
    const spender = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
    const value = 1000;
    const deadline = 100;

    let sig = ethers.utils.splitSignature(
        await guy._signTypedData(
            {
            name,
            version,
            chainId,
            verifyingContract: token
            },
            {
            Permit: [
                {
                name: "owner",
                type: "address",
                },
                {
                name: "spender",
                type: "address",
                },
                {
                name: "value",
                type: "uint256",
                },
                {
                name: "nonce",
                type: "uint256",
                },
                {
                name: "deadline",
                type: "uint256",
                },
            ],
            },
            {
            owner: guy.address,
            spender,
            value,
            nonce,
            deadline,
            }
        )
    )
    console.log(sig);
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