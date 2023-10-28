const {loadFixture} = require("@nomicfoundation/hardhat-toolbox/network-helpers")
const { ethers } = require("hardhat")

describe("FactoryAssembly", function(){
    
    const salt = ethers.keccak256(ethers.encodeBytes32String("Hello World"));
    const address = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
    const foo = 10;

    console.log("salt:"+salt)

    async function deploy(){
        const [owner] = await ethers.getSigners();
        const FactoryAssemblyFactory = await ethers.getContractFactory("FactoryAssembly")
        const factoryAssembly = await FactoryAssemblyFactory.deploy();
        return {owner, factoryAssembly};
    }

    it("calculateAddr",async function(){
        const {owner, factoryAssembly} = await loadFixture(deploy);
        const bytecode = await factoryAssembly.calculateBytecode(address,foo);
        const c_address = await factoryAssembly.calculateAddr(bytecode,salt);
        console.log("calculateadd : "+ c_address);
    })

    // it("deploy", async function(){
    //     const {owner, factoryAssembly} = await loadFixture(deploy);
    //     factoryAssembly.on("ContractDepoly", (address,salt) => {
    //         // THIS LINE NEVER GETS HIT
    //         console.log(address)
    //         console.log(salt)
    //         resolve(true);
    //       });
    //     const tx = await factoryAssembly.deployByNew(address,foo,salt);
    //     await tx.wait();
    // })

    //当你使用assembly 去测试create2的时候，需要将上面的deploy的测试区注释。你没办法同时部署两个相同的合约
    it("deploy assembly", async function(){
        const {owner, factoryAssembly} = await loadFixture(deploy);
        factoryAssembly.on("ContractDepoly", (address,salt) => {
            // THIS LINE NEVER GETS HIT
            console.log(address)
            console.log(salt)
            resolve(true);
          });

        const bytecode = await factoryAssembly.calculateBytecode(address,foo);
        const tx = await factoryAssembly.deployByAssembly(bytecode,salt);
        await tx.wait();
    })

})