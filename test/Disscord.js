const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Disscord", () => {
    let disscord, serversBefore;
    // addresses
    let deployer, admin1, user1;

    // server details
    let serverName = "Blockchain";
    let about = "All things blockchain!";
    let servers, channels, users;

    // channel details
    let channelName = "getting started";
    let channelAbout = "getting started with blockchain development";
    let serverId;

    // user details
    let username = "jim_bantu";

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

        // create user
        await disscord.connect(user1).joinServer(username, serverId);
        users = await disscord.getServerUsers();
        // console.log("Users: ", users)
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
            expect(users[0].user.username).to.be.equal(username);
            expect(users[0].server.id).to.be.equal(serverId);
            expect(users.length).to.be.equal(1);
        })
    })

    describe("ChannelUser", async () => {
        it("allows a user to subscribe to a channel", async () => {
            let serverId = servers[0].id
            let channelId = channels[0].id;
            await disscord.connect(user1).joinChannel(serverId, channelId);
            let channelUsers = await disscord.getChannelUsers();
            expect(channelUsers.length).to.be.equal(1);
        })
    })

    describe("Messages", async () => {
        it("allows a user to send a message in the channel", async () => {
            let serverId = servers[0].id
            let channelId = channels[0].id;
            let message = "Welcome to the channel";
            await disscord.connect(user1).sendMessage(serverId, channelId, message);
            let messages = await disscord.getMessages();
            expect(messages.length).to.be.equal(1);
            expect(messages[0].message).to.be.equal(message);
        })
    })
});
