const main = async () => {
    const [guy, randomGuy] = hre.ethers.getSigners();

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

    const _0ow = await marketContract.getOwner(nftContract.address, 0);
    console.log("NFT#0's owner is", _0ow);

    const _1ow = await marketContract.getOwner(nftContract.address, 1);
    console.log("NFT#1's owner is", _1ow);

    const _1status = await marketContract.getListStatus(nftContract.address, 1);
    console.log("NFT#1 listed status:", _1status);

    const _buy = await marketContract.connect(randomGuy).buyNFT(nftContract.address, 1);
    const _1own = await marketContract.getOwner(nftContract.address, 1);
    console.log("NFT#1's owner is", _1own);


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