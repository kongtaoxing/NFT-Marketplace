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

    // const EIP712Domain = [  
    //     { name: "name", type: "string" },  
    //     { name: "version", type: "string" },  
    //     { name: "chainId", type: "uint256" },  
    //     { name: "verifyingContract", type: "address" },
    // ];
 
    // const { chainId } = library.network;
    // const _domain = {    
    //     name: nftContract.address,    
    //     version: "1",    
    //     chainId,    
    //     verifyingContract: nftContract.address 
    // };

    const __list = await marketContract.listNFT(nftContract.address, 3, ethwei.parseEther('1'));
    console.log('listed');
    const _updatelist = await marketContract.updatePrice(nftContract.address, 3, ethwei.parseEther('10'))
    console.log('updated');
    const _buy_ = await marketContract.connect(randomGuy).buyNFT(nftContract.address, 3, {value: ethwei.parseEther('100')});
    console.log('bought');
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