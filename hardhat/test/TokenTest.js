const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Token contract", function () {

  async function deployTokenFixture() {

    const [owner, addr1, addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token");
    const hardhatToken = await Token.deploy();
    await hardhatToken.deployed();

    const Logic = await ethers.getContractFactory("Logic");
    const logicToken = await Token.deploy();
    await logicToken.deployed();

    await hardhatToken.setImpl(logicToken.address);

    return { Token, hardhatToken, logicToken, owner, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      // We use loadFixture to setup our environment, and then assert that
      // things went well
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);

      // `expect` receives a value and wraps it in an assertion object. These
      // objects have a lot of utility methods to assert values.

      // This test expects the owner variable stored in the contract to be
      // equal to our Signer's owner.
      expect(await hardhatToken.owner()).to.equal(owner.address);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
      const ownerBalance = await hardhatToken.balanceOf(owner.address);
      expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
    });
  });

  /* describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );
      // Transfer 50 tokens from owner to addr1
      await expect(
        hardhatToken.transfer(addr1.address, 50)
      ).to.changeTokenBalances(hardhatToken, [owner, addr1], [-50, 50]);

      // Transfer 50 tokens from addr1 to addr2
      // We use .connect(signer) to send a transaction from another account
      await expect(
        hardhatToken.connect(addr1).transfer(addr2.address, 50)
      ).to.changeTokenBalances(hardhatToken, [addr1, addr2], [-50, 50]);
    });

    it("should emit Transfer events", async function () {
      const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );

      // Transfer 50 tokens from owner to addr1
      await expect(hardhatToken.transfer(addr1.address, 50))
        .to.emit(hardhatToken, "Transfer")
        .withArgs(owner.address, addr1.address, 50);

      // Transfer 50 tokens from addr1 to addr2
      // We use .connect(signer) to send a transaction from another account
      await expect(hardhatToken.connect(addr1).transfer(addr2.address, 50))
        .to.emit(hardhatToken, "Transfer")
        .withArgs(addr1.address, addr2.address, 50);

    }); */

  it("自己的测试", async function () {
    const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
      deployTokenFixture
    );
    await expect(hardhatToken.transfer(addr1.address, 50))
      .to.emit(hardhatToken, "Fuck")
      .withArgs("nothing");

    /* await expect(owner.sendTransaction({
      to: hardhatToken.address,
      data: "0x"  // 0x  调用了 fallback 
    }))
      .to.emit(hardhatToken, "Bro")
      .withArgs("fallback"); */

    // 通过 fallback 调用  Logic 里面的 SetUint256Param
    await expect(owner.sendTransaction({
      to: hardhatToken.address,
      data: "cd4fe8cd0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000"  
    }))
      .to.emit(hardhatToken, "Bro")
      .withArgs("fallback");
      
  });

  /* it("Should fail if sender doesn't have enough tokens", async function () {
    const { hardhatToken, owner, addr1 } = await loadFixture(
      deployTokenFixture
    );
    const initialOwnerBalance = await hardhatToken.balanceOf(owner.address);

    // Try to send 1 token from addr1 (0 tokens) to owner (1000 tokens).
    // `require` will evaluate false and revert the transaction.
    await expect(
      hardhatToken.connect(addr1).transfer(owner.address, 1)
    ).to.be.revertedWith("Not enough tokens");

    // Owner balance shouldn't have changed.
    expect(await hardhatToken.balanceOf(owner.address)).to.equal(
      initialOwnerBalance
    );
  }); */

});