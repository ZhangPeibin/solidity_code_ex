const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Math", function () {
    async function deployMath(){
        const [owner, otherAccount] = await ethers.getSigners();
        const Math = await ethers.getContractFactory("Math");
        const math = await Math.deploy();
        return {math,owner}
    }

    describe("ceilDiv",function(){
        it("ceil div",async function(){
            const { math } = await loadFixture(deployMath);

            const a= 4;
            const b = 3
            const result = await math.ceilDiv(a,b);
            console.log(result)
        })
    })
})