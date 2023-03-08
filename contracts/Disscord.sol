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

    struct User {
        bytes32 id;
        string username;
        address userAddress;
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct ServerUser {
        Server server;
        User user;
        uint256 createdAt;
    }

    Server[] public servers;
    Channel[] public channels;
    User[] public users;
    ServerUser[] public serverUsers;

    modifier serverExists(bytes32 _serverId) {
        Server memory server = findServer(_serverId);
        require(server.id != "", "server matching id doesn't exist");
        _;
    }

    modifier requireUniqueUserAddress(address _address) {
        User memory user = findUserByAddress(_address);
        require(user.userAddress != _address, "user matching address exists");
        _;
    }

    modifier requireUniqueUsername(string memory _username) {
        User memory user = findUserByUsername(_username);
        require(user.id == "", "user matching username exists");
        _;
    }

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

    function createChannel(string memory _name, string memory _about, bytes32 _serverId) serverExists(_serverId) public returns(Channel memory){
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

    function joinServer(string memory _username, bytes32 _serverId) serverExists(_serverId) requireUniqueUserAddress(msg.sender) requireUniqueUsername(_username) public returns(ServerUser memory) {
        // assemble user details
        User memory user;
        user.createdAt = block.timestamp;
        user.id = bytes32(
            keccak256(
                abi.encodePacked(_username, _serverId, msg.sender, user.createdAt)
            )
        );
        user.username = _username;
        user.userAddress = msg.sender;

        // assemble serverUser details
        ServerUser memory serverUser;
        serverUser.user = user;
        serverUser.server = findServer(_serverId);
        serverUser.createdAt = user.createdAt;

        // save to the blockchain
        users.push(user);
        serverUsers.push(serverUser);

        return serverUser;
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

    function findUserByAddress(address _address) public view returns(User memory) {
        User memory user;
        for(uint i = 0; i < users.length; i++) {
            if(users[i].userAddress == _address) {
                user = users[i];
            }
        }

        return user;
    }

    function findUserByUsername(string memory _username) public view returns(User memory) {
        User memory user;
        for(uint i = 0; i < users.length; i++) {
            if(keccak256(abi.encodePacked(users[i].username)) != keccak256(abi.encodePacked(_username))) {
                user = users[i];
            }
        }

        return user;
    }

    function getServerUsers() public view returns(ServerUser[] memory) {
        return serverUsers;
    }
}
