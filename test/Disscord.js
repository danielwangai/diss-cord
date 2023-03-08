const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Disscord", () => {
    let disscord, serversBefore;
    // addresses
    let deployer, admin1, user1;

    // server details
    let serverName = "Blockchain";
    let about = "All things blockchain!";
    let servers, channels;

    // channel details
    let channelName = "getting started";
    let channelAbout = "getting started with blockchain development";
    let serverId;

    beforeEach(async () => {
        [deployer, admin1, user1] = await ethers.getSigners();
        const Disscord = await ethers.getContractFactory("Disscord");
        disscord = await Disscord.deploy();

        serversBefore = await disscord.getServers();
        await disscord.createServer(serverName, about);
        servers = await disscord.getServers()

        // create channel
        serverId = servers[0].id;
        await disscord.connect(admin1).createChannel(channelName, channelAbout, serverId);
        channels = await disscord.getChannels();
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

    describe("Channel", async () => {
        it("creates a new channel", async () => {
            let channel = channels[0];
            expect(channel.name).to.be.equal(channelName);
            expect(channel.about).to.be.equal(channelAbout);
            expect(channel.serverId).to.be.equal(serverId);
            expect(channel.createdBy).to.be.equal(admin1.address);
        });
    });

    describe("ServerUser", async () => {
        it("admits new user to server", async () => {
            let username = "jim_bantu";
            let serverId = servers[0].id;
            await disscord.connect(user1).joinServer(username, serverId);
            let serverUsers = await disscord.getServerUsers();
            expect(serverUsers[0].user.username).to.be.equal(username);
            expect(serverUsers[0].server.id).to.be.equal(serverId);
        })
    })
});
