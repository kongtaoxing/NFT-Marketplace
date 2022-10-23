const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory("testNFT");
    const nftContract = await nftContractFactory.deploy();

    const marketContractFactory = await hre.ethers.getContractFactory("NFTMarket");
    const marketContract = await marketContractFactory.deploy();

    const mintNFT = await nftContract.mint();
    await mintNFT.wait();

    const _mintNFT = await nftContract.mint();
    await _mintNFT.wait();

    const _approve = await nftContract.setApprovalForAll(marketContract.address, true);
    const _list = await marketContract.listNFT(nftContract.address, 1, 100);

    const _0status = await marketContract.getListStatus(nftContract.address, 0);
    console.log("NFT#0 listed status:", _0status);

    const _1status = await marketContract.getListStatus(nftContract.address, 1);
    console.log("NFT#0 listed status:", _1status);

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