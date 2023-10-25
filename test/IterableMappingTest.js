const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("IterableMapping", function () {
    async function deployMath(){
        const [owner, otherAccount] = await ethers.getSigners();
        const IterableMappingLib = await ethers.getContractFactory("IterableMapping");
        const iterableMappingLib = await IterableMappingLib.deploy();

        const TestIterableMapping = await ethers.getContractFactory("TestIterableMap",{
            libraries:{
                IterableMapping:iterableMappingLib
            }
        });
        const testIterableMapping = await TestIterableMapping.deploy();
        return {testIterableMapping,owner}
    }

    describe("TestIterableMapping",function(){
        it("map actions",async function(){
            const { testIterableMapping } = await loadFixture(deployMath);  
            await testIterableMapping.testIterableMap()
            expect(await testIterableMapping.getMapSize()).to.equal(3);
        })
    })
})