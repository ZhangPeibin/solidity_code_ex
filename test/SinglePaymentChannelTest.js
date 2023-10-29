const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers")
const { ethers } = require("hardhat")
const {expect} = require("chai")

describe("SimplePaymentChannel", function () {
    async function deploySimplePaymment() {
        const [owner, recipient] = await ethers.getSigners();
        const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
        const SimplePaymentChannelFactory = await ethers.getContractFactory("SimplePaymentChannel");
        const recipientAddress = await recipient.getAddress();
        const simplePaymentChannel = await SimplePaymentChannelFactory.deploy(recipientAddress, ONE_YEAR_IN_SECS,{ value: 20 });
        return { simplePaymentChannel, owner, recipient };
    }
    describe("Test Depoly", async function(){
        it("log address", async function () {
            const { simplePaymentChannel, owner, recipient } = await loadFixture(deploySimplePaymment);
            console.log("contract address : " + await simplePaymentChannel.getAddress());
        })
    })

    describe("Simple Pay", async function () {
        it("signature",async function(){
            const { simplePaymentChannel, owner, recipient } = await loadFixture(deploySimplePaymment);
            const ethSignedMessage = await simplePaymentChannel.messageHash(await simplePaymentChannel.getAddress(), 10);
            console.log("合约_消息Hash:"+ethSignedMessage);
    
            const account = await simplePaymentChannel.getAddress();
            const msgHash = ethers.solidityPackedKeccak256(
                ['address','uint256'],
                [account,10]
            );
            console.log("ethers_消息Hash:"+msgHash)
            const signature = await owner.signMessage(ethers.getBytes(msgHash));
            console.log("签名:"+signature);
            expect( await simplePaymentChannel.isValidSignature(10,signature)).to.equal(true);
        })

        it("contract banlance", async function(){
            const { simplePaymentChannel, owner, recipient } = await loadFixture(deploySimplePaymment);
            const ownerBalance = await ethers.provider.getBalance(owner);
            const recipientBalance = await ethers.provider.getBalance(recipient);
            const simplePaymentChannelBalance = await ethers.provider.getBalance(simplePaymentChannel);
            expect(await ethers.provider.getBalance(simplePaymentChannel)).to.equal(20);
        })

        it("close", async function(){
            const { simplePaymentChannel, owner, recipient } = await loadFixture(deploySimplePaymment);
            const recipientBalance = await ethers.provider.getBalance(recipient);
            console.log("recipient:"+recipientBalance);
            const account = await simplePaymentChannel.getAddress();
            const msgHash = ethers.solidityPackedKeccak256(
                ['address','uint256'],
                [account,10]
            );
            console.log("ethers_消息Hash:"+msgHash)
            const signature = await owner.signMessage(ethers.getBytes(msgHash));
            console.log("签名:"+signature);
            await simplePaymentChannel.connect(recipient).close(10,signature);

            expect(await ethers.provider.getBalance(simplePaymentChannel)).to.equal(0);
        })
        
    })

})