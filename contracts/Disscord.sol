// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Disscord {
    struct Server {
        bytes32 id;
        string name;
        string about;
        address payable createdBy;
        uint256 createdAt;
    }

    struct Channel {
        bytes32 id;
        string name;
        string about;
        bytes32 serverId;
        address payable createdBy;
        uint256 createdAt;
        uint256 updatedAt;
    }

    Server[] public servers;
    Channel[] public channels;

    function createServer(string memory _name, string memory _about) public returns(Server memory) {
        Server memory server;
        server.createdAt = block.timestamp;
        server.id = bytes32(
            keccak256(
                abi.encodePacked(_name, _about, msg.sender, server.createdAt)
            )
        );
        server.name = _name;
        server.about = _about;
        server.createdBy = payable(msg.sender);

        servers.push(server);
        return server;
    }

    function createChannel(string memory _name, string memory _about, bytes32 _serverId) public returns(Channel memory){
        Server memory server = findServer(_serverId);
        require(server.id != "", "server matching id doesn't exist");

        Channel memory channel;
        channel.createdAt = block.timestamp;
        channel.id = bytes32(
            keccak256(
                abi.encodePacked(_name, _about, _serverId, msg.sender, channel.createdAt)
            )
        );
        channel.name = _name;
        channel.about = _about;
        channel.serverId = _serverId;
        channel.createdBy = payable(msg.sender);

        channels.push(channel);
        return channel;
    }

    function getServers() public view returns(Server[] memory) {
        return servers;
    }

    function findServer(bytes32 id) public view returns(Server memory) {
        Server memory server;
        for(uint i = 0; i < servers.length; i++) {
            if(servers[i].id == id) {
                server = servers[i];
            }
        }

        return server;
    }

    function getChannels() public view returns(Channel[] memory) {
        return channels;
    }

    function findChannel(bytes32 id) public view returns(Channel memory) {
        Channel memory channel;
        for(uint i = 0; i < channels.length; i++) {
            if(channels[i].id == id) {
                channel = channels[i];
            }
        }

        return channel;
    }
}
