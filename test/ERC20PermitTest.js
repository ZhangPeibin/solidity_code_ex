const {
    loadFixture
} = require("@nomicfoundation/hardhat-toolbox/network-helpers")
const { ethers } = require("hardhat")
const { expect } = require("chai")

async function deployERC20Permit() {
    const [owner, spender] = await ethers.getSigners();
    const ERC20PermitFactory = await ethers.getContractFactory("ERC2Permit");
    const token = await ERC20PermitFactory.deploy("Test", "Test", 18);
    return { token, owner, spender };
}

describe("ERC20Permit", function () {
    it("DOMAIN_SEPARATOR", async function () {
        const { token } = await loadFixture(deployERC20Permit);
        const tokenAddress = await token.getAddress();
        const { chainId } = await ethers.provider.getNetwork()
        const DOMAIN_SEPARATOR = await token.DOMAIN_SEPARATOR();
        var digest = ethers.TypedDataEncoder.hashDomain({
            name: "Test",
            version: "1",
            chainId,
            verifyingContract: tokenAddress
        });
        expect(digest).to.be.equal(DOMAIN_SEPARATOR);
    })

    describe("permit", async function () {
        it("accepts owner signature", async function () {
            const { token, owner, spender } = await loadFixture(deployERC20Permit);
            const { chainId } = await ethers.provider.getNetwork()
            const tokenAddress = await token.getAddress();
            console.log(chainId);
            console.log(tokenAddress);

            const signature = await owner.signTypedData(
                {
                    name: "Test",
                    version: "1",
                    chainId: chainId,
                    verifyingContract: tokenAddress
                },
                {
                    Permit: [
                        {
                            name: 'owner',
                            type: 'address',
                        },
                        {
                            name: 'spender',
                            type: 'address',
                        },
                        {
                            name: 'value',
                            type: 'uint256',
                        },
                        {
                            name: 'nonce',
                            type: 'uint256',
                        },
                        {
                            name: 'deadline',
                            type: 'uint256',
                        },
                    ],
                },
                {
                    owner: owner.address,
                    spender: spender.address,
                    value: BigInt(10),
                    nonce: 0,
                    deadline: Number.MAX_SAFE_INTEGER,
                });
            console.log(signature);
            const { v, r, s } = ethers.Signature.from(signature)
            
            const receipt = await token.permit(owner.address,spender.address,
                BigInt(10),Number.MAX_SAFE_INTEGER,v,r,s);
            
            expect(await token.allowance(owner.address,spender.address)).to.equal(BigInt(10));
           
        })


    })
})