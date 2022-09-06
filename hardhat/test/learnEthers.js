const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Demo', () => {
    let deployer;
    let demoContract;

    before(async () => {
        [deployer] = await ethers.getSigners();
        const factory = await ethers.getContractFactory('Demo');
        demoContract = await factory.deploy().then((res) => res.deployed());
    });

    it('should invoke the fallback function', async () => {
        const nonExistentFuncSignature = 'nonExistentFunc(uint256,uint256)';
        const fakeDemoContract = new ethers.Contract(
            demoContract.address,
            [
                ...demoContract.interface.fragments,
                `function ${nonExistentFuncSignature}`,
            ],
            deployer,
        );
        const tx = fakeDemoContract[nonExistentFuncSignature](8, 9);
        await expect(tx)
            .to.emit(demoContract, 'Error')
            .withArgs('call of a non-existent function');
    });

});