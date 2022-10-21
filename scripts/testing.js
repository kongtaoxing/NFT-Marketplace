const Marketplace =  require("../src/Marketplace.json");

const main = async () => {
const [owner, randomGuy] = await hre.ethers.getSigners();

const MyContract = await ethers.getContractFactory("NFTMarketplace");
const contract = await MyContract.deploy();
await contract.deployed();
//const contract = await MyContract.attach(Marketplace.address);

console.log("Contract deployed to", contract.address);
const _owner = await contract.getOwner();
console.log("The owner is", _owner);

// testing change owner
// const change = await contract.changeOwner(randomGuy.address);
// await change.wait();
// const newOwner = await contract.getOwner();
// console.log("The new owner is", newOwner);

const _creat = await contract.createToken("", 10, {value:hre.ethers.utils.parseEther("0.01")});
const _creat1 = await contract.createToken("", 10, {value:hre.ethers.utils.parseEther("0.01")});
const _creat2 = await contract.createToken("", 10, {value:hre.ethers.utils.parseEther("0.01")});

console.log("Create and list successfully!");

const listed = await contract.getAllNFTs();
console.log("All NFTs", listed);

const myNFT = await contract.getMyNFTs();
console.log("My NFTs", myNFT);

// const _change = await contract.changeOwner(owner.address);
// // Now you can call functions of the contract
// var vals = await contract.getListPrice();
// console.log(vals);

/*const provider = new ethers.providers.Web3Provider(window.ethereum)
const signer = provider.getSigner();
const addrsign = await signer.getAddress();

let contract = new ethers.Contract(Marketplace.address, Marketplace.abi, signer)
let transaction = await contract.getAllNFTs()
console.log(transaction);*/
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


