const {time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers")
const { ethers } = require("hardhat")
const { expect } = require("chai")

describe("Crowdfund", function () {

    async function deployCrowdfund() {
        const MIN_IN_SECS =  60 * 60;
        const startTime = (await time.latest()) + 10;
        const endtime = (await time.latest()) + MIN_IN_SECS;

        const [owner] = await ethers.getSigners();

        const HelloERC20Factory = await ethers.getContractFactory("HelloERC20");
        const helloERC20Contract = await HelloERC20Factory.deploy(10000000);

        const CrowdfundFactory = await ethers.getContractFactory("CrowdFund");
        const crowdfundContract = await CrowdfundFactory.deploy(await helloERC20Contract.getAddress());
        return { crowdfundContract, helloERC20Contract, owner ,startTime,endtime};
    }

    describe("Deploy ", async function () {
        it("Test Deploy", async function () {
            const { crowdfundContract, helloERC20Contract, owner } = await loadFixture(deployCrowdfund);
            expect(await crowdfundContract.token()).to.equal(await helloERC20Contract.getAddress());
        })

        it("Test mint", async function () {
            const { crowdfundContract, helloERC20Contract, owner } = await loadFixture(deployCrowdfund);
            const [a1,a2] = await ethers.getSigners();
            await helloERC20Contract.connect(a2).mint();
            expect(await helloERC20Contract.balanceOf(await a2.getAddress())).to.equal(10000);
        })
    })

    describe("Crowd", async function () {
        it("Test create crowd", async function () {
            const { crowdfundContract, helloERC20Contract, owner ,startTime,endtime} = await loadFixture(deployCrowdfund);
            crowdfundContract.on("Launch", (count, address, goal, start, end) => {
                // THIS LINE NEVER GETS HIT
                console.log(count)
                console.log(goal)
                resolve(true);
            });
            await crowdfundContract.connect(owner).launch(1000, startTime, endtime);
        })

        it("Test cancel crowd" , async function(){
            const { crowdfundContract, helloERC20Contract, owner,startTime,endtime } = await loadFixture(deployCrowdfund);
            await crowdfundContract.connect(owner).launch(1000, startTime, endtime);

            crowdfundContract.on("Cancel", (id) => {
                // THIS LINE NEVER GETS HIT
                console.log(id)
                resolve(true);
            });
            await crowdfundContract.connect(owner).cancel(1);
        })

        it("Test pledge crowd & cancel" , async function(){
            const { crowdfundContract, helloERC20Contract, owner,startTime,endtime } = await loadFixture(deployCrowdfund);
            await crowdfundContract.connect(owner).launch(1000, startTime, endtime);
            await crowdfundContract.connect(owner).cancel(1);
            await expect(crowdfundContract.pledge(1,10)).to.be.revertedWith("ended");
        })

        it("Test pledge", async function(){
            const { crowdfundContract, helloERC20Contract, owner,startTime,endtime } = await loadFixture(deployCrowdfund);
            await crowdfundContract.connect(owner).launch(1000, startTime, endtime);
            await helloERC20Contract.connect(owner).approve(await crowdfundContract.getAddress(),1000);
            crowdfundContract.on("Pledge", (id,sender,amount) => {
                // THIS LINE NEVER GETS HIT
                console.log(id)
                console.log(sender)
                console.log(amount)
                resolve(true);
            });
            await new Promise(resolve => setTimeout(resolve, 10000)); // 10000 毫秒 = 10 秒
            const oldBalance = await helloERC20Contract.balanceOf(await owner.getAddress());
            await crowdfundContract.connect(owner).pledge(1,100);
            expect(await helloERC20Contract.balanceOf(await owner.getAddress())).to.equal(oldBalance-BigInt(100));
        })

        it("Test unpledge", async function(){
            const { crowdfundContract, helloERC20Contract, owner,startTime,endtime } = await loadFixture(deployCrowdfund);
            await crowdfundContract.connect(owner).launch(1000, startTime, endtime);
            await helloERC20Contract.connect(owner).approve(await crowdfundContract.getAddress(),1000);
            crowdfundContract.on("Pledge", (id,sender,amount) => {
                // THIS LINE NEVER GETS HIT
                console.log(id)
                console.log(sender)
                console.log(amount)
                resolve(true);
            });
            await new Promise(resolve => setTimeout(resolve, 10000)); // 10000 毫秒 = 10 秒
            const oldBalance = await helloERC20Contract.balanceOf(await owner.getAddress());
            await crowdfundContract.connect(owner).pledge(1,100);
            expect(await helloERC20Contract.balanceOf(await owner.getAddress())).to.equal(oldBalance-BigInt(100));
            await crowdfundContract.connect(owner).unpledge(1,50);
            expect(await helloERC20Contract.balanceOf(await owner.getAddress())).to.equal(oldBalance-BigInt(50));
        })

        it("Test claim", async function(){
            const { crowdfundContract, helloERC20Contract, owner,startTime,endtime } = await loadFixture(deployCrowdfund);
            await crowdfundContract.connect(owner).launch(10, startTime, endtime);
            await helloERC20Contract.connect(owner).approve(await crowdfundContract.getAddress(),1000);
            crowdfundContract.on("Pledge", (id,sender,amount) => {
                // THIS LINE NEVER GETS HIT
                console.log(id)
                console.log(sender)
                console.log(amount)
                resolve(true);
            });
            await new Promise(resolve => setTimeout(resolve, 10000)); // 10000 毫秒 = 10 秒
            const oldBalance = await helloERC20Contract.balanceOf(await owner.getAddress());
            await crowdfundContract.connect(owner).pledge(1,100);
            await crowdfundContract.connect(owner).claim(1);
            expect(await helloERC20Contract.balanceOf(await owner.getAddress())).to.equal(oldBalance);
        })

    })  
})