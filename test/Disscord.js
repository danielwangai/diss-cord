const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Disscord", () => {
    let disscord, serversBefore;
    let deployer, owner1;
    let serverName = "Blockchain";
    let about = "All things blockchain!";

    beforeEach(async () => {
        [deployer, owner1] = await ethers.getSigners();
        const Disscord = await ethers.getContractFactory("Disscord");
        disscord = await Disscord.deploy();

        serversBefore = await disscord.getServers();
        await disscord.createServer(serverName, about);
    })

    describe("Server", async () => {
        it("creates a new disscord server", async () => {
            expect(serversBefore.length).to.be.equal(0);
            const serversAfter = await disscord.getServers();
            expect(serversAfter.length).to.be.equal(1);
            const newStore = serversAfter[0];
            expect(newStore.name).to.be.equal(serverName);
            expect(newStore.about).to.be.equal(about);
        });
    });
});
