const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("testNFT", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("testNFT");
    const greeter = await Greeter.deploy();
    await greeter.deployed();

    //expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.mint();

    // wait until the transaction is mined
    await setGreetingTx.wait();

    //expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
