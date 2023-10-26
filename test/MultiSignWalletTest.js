const {
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("MutiSignWallet", function () {
    async function deployMutiSignWallet() {
        const [owner, a1, a2, a3] = await ethers.getSigners();
        const MutiSignWallet = await ethers.getContractFactory("MultiSignWallet");
        const multiSignWallet = await MutiSignWallet.deploy([owner, a1, a2, a3], 3,{value:20});
        return { multiSignWallet, owner, a1, a2, a3 };
    }

    describe("Test Add Transaction", function () {
        it("test ", async function () {
            const { multiSignWallet, owner, a1, a2, a3 } = await loadFixture(deployMutiSignWallet);
            expect((await multiSignWallet.getOwners()).length).to.equal(4);

            let balance =  await ethers.provider.getBalance(a3);
            console.log(balance);
            const contractBalance =  await ethers.provider.getBalance(multiSignWallet);
            console.log(contractBalance);

            await multiSignWallet.connect(owner).submitTransaction(a3, 10, ethers.encodeBytes32String("hello"));
            // console.log(await multiSignWallet.getTransaction(0));
            expect((await multiSignWallet.getTransaction(0))[0]).to.equal(await a3.getAddress());
            expect((await multiSignWallet.getTransaction(0))[1]).to.equal(10);

            await multiSignWallet.connect(a1).confirmTransaction(0);
            await multiSignWallet.connect(owner).confirmTransaction(0);
            await expect(multiSignWallet.connect(a2).executeTransaction(0)).to.be.revertedWith(
                "cannot execute tx"
            );
            
            await multiSignWallet.connect(a2).confirmTransaction(0);
            await expect(multiSignWallet.connect(a2).executeTransaction(0)).not.to.be.reverted;
            
            // balance =  await ethers.provider.getBalance(a3);
            // console.log(balance);
            expect(await ethers.provider.getBalance(a3)).to.equal(balance+BigInt(10))
        })
    })
})