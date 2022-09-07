const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Token contract", function () {

    async function deployTokenFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();

        const Token = await ethers.getContractFactory("Token");
        const token = await Token.deploy();
        await token.deployed();

        const Logic = await ethers.getContractFactory("Logic");
        const logic = await Logic.deploy();
        await logic.deployed();

        return { Token, Logic, token, logic, owner, addr1, addr2 };
    }

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            const { token, owner } = await loadFixture(deployTokenFixture);
            expect(await token.owner()).to.equal(owner.address);
        });

        it("Should assign the total supply of tokens to the owner", async function () {
            const { token, owner } = await loadFixture(deployTokenFixture);
            const ownerBalance = await token.balanceOf(owner.address);
            expect(await token.totalSupply()).to.equal(ownerBalance);
        });
    });

    describe("Transactions", function () {
        it("Should transfer tokens between accounts", async function () {
            const { token, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            // Transfer 50 tokens from owner to addr1
            await expect(
                token.transfer(addr1.address, 50)
            ).to.changeTokenBalances(token, [owner, addr1], [-50, 50]);
            // Transfer 50 tokens from addr1 to addr2
            // We use .connect(signer) to send a transaction from another account
            await expect(
                token.connect(addr1).transfer(addr2.address, 50)
            ).to.changeTokenBalances(token, [addr1, addr2], [-50, 50]);
        });
        it("should emit Transfer events", async function () {
            const { token, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            // Transfer 50 tokens from owner to addr1
            await expect(token.transfer(addr1.address, 50))
                .to.emit(token, "Transfer")
                .withArgs(owner.address, addr1.address, 50);
            // Transfer 50 tokens from addr1 to addr2
            // We use .connect(signer) to send a transaction from another account
            await expect(token.connect(addr1).transfer(addr2.address, 50))
                .to.emit(token, "Transfer")
                .withArgs(addr1.address, addr2.address, 50);
        });

        describe("自己的测试", function () {

            it("event 事件", async function () {
                const { Token, Logic, token, logic, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
                await expect(token.transfer(addr1.address, 50))
                    .to.emit(token, "Fuck")
                    .withArgs("nothing");

                /* await expect(owner.sendTransaction({
                  to: hardhatToken.address,
                  data: "0x"  // 0x  调用了 fallback     走不通的  
                }))
                  .to.emit(hardhatToken, "Bro")
                  .withArgs("fallback"); */

                // 通过 fallback 调用  Logic 里面的 SetUint256Param    走不通  垃圾hardhat 
                /*   await expect(owner.sendTransaction({
                    to: hardhatToken.address,
                    data: "0xcd4fe8cd0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000"  
                  }))
                    .to.emit(hardhatToken, "Bro")
                    .withArgs("fallback"); */
            });

            /* it("--final result--", async function () {
        
                const Token = await ethers.getContractFactory("Token");
                const token = await Token.deploy();
                await token.deployed();
        
                const Logic = await ethers.getContractFactory("Logic");
                const logic = await Logic.deploy();
                await logic.deployed();
        
                await token.setImplementation(logic.address);
        
                let impl = await token.getImplementation();
                console.log("impl:" + impl);
        
                // Proxy handle : StorageImplementation attached to storage address
                // Trough proxy, you can interact with storage as if it was an instance
                // of StorageImplementation.
                const proxy = await Logic.attach(token.address);
                let helloResp = await proxy.hello();
                expect(helloResp).to.equal("hello");
            }); */


            // callback 方式调用的目前的唯一解
            it("--final result--", async function () {
                const { Token, Logic, token, logic, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
                await token.setImplementation(logic.address);

                let impl = await token.getImplementation();
                console.log("impl:" + impl);

                const proxy = await Logic.attach(token.address);

                let helloResp = await proxy.hello();
                // expect(helloResp).to.equal("hello");
                expect(helloResp).to.emit(token, "Bro")
                .withArgs("fallback");

                let setResp = await proxy.SetUint256Param("a", 4);
                expect(setResp).to.emit(token, "Bro")
                    .withArgs("fallback");

                let getResp = await proxy.GetUint256Param("a");
                expect(getResp).to.equal(4);
                expect(getResp).to.emit(token, "Bro")
                    .withArgs("fallback");
            });
        });
    });
});
// hardhat 对fallback的东西 不太好用  非常麻烦  不过最终还是弄好了   记录下 
// 还有些写法非常有意思    before(async () => {  });   
//                       it('TEST', async () => {     });
// https://stackoverflow.com/questions/72584559/how-to-test-the-solidity-fallback-function-via-hardhat 
// https://ethereum.stackexchange.com/questions/128321/fallback-not-executing 
