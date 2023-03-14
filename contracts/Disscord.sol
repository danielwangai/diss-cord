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

    struct ServerChannel {
        Server server;
        Channel channel;
        uint256 createdAt;
    }

    struct ServerUser {
        Server server;
        User user;
        uint256 createdAt;
    }

    struct ServerChannelUser {
        bytes32 serverId;
        bytes32 channelId;
        address user;
        uint256 createdAt;
    }

    struct Message {
        bytes32 id;
        string message;
        bytes32 serverId;
        bytes32 channelId;
        address createdBy;
        uint256 createdAt;
        uint256 updatedAt;
    }

    Server[] public servers;
    Channel[] public channels;
    User[] public users;
    ServerUser[] public serverUsers;
    ServerChannel[] public serverChannels;
    ServerChannelUser[] public serverChannelUsers;
    Message[] public messages;

    modifier serverExists(bytes32 _serverId) {
        Server memory server = findServerById(_serverId);
        require(server.id != "", "server matching id doesn't exist");
        _;
    }

    modifier channelExists(bytes32 _channelId) {
        Channel memory channel = findChannelById(_channelId);
        require(channel.id != "", "channel matching id doesn't exist");
        _;
    }

    modifier userExists(address _address) {
        User memory user = findUserByAddress(_address);
        require(user.id != "", "user matching address doesn't exist");
        _;
    }

    modifier requireUniqueUserAddress(address _address) {
        User memory user = findUserByAddress(_address);
        require(user.userAddress != _address, "user matching address exists");
        _;
    }

//    modifier requireUserNotAlreadyChannelMember(bytes32 _channelId, address _address) {
//        ServerChannelUser memory channelUser = findUserInChannel(_channelId, _address);
//        require(channelUser.channel.id == "" && channelUser.user.id == "", "the user is already a member of this channel");
//        _;
//    }
//
//    modifier requireUserIsServerMember(bytes32 _serverId, address _address) {
//        ServerUser memory serverUser = findUserInServer(_serverId, _address);
//        require(serverUser.server.id != "" && serverUser.user.id != "", "user must already be a member of the server");
//        _;
//    }

    modifier channelExistsInServer(bytes32 _serverId, bytes32 _channelId) {
        ServerChannel memory serverChannel = findChannelInServer(_serverId, _channelId);
        require(serverChannel.server.id != "" && serverChannel.channel.id != "", "");
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

    function createChannel(string memory _name, string memory _about, bytes32 _serverId)
    // serverExists(_serverId)
    public returns(Channel memory){
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

        // server
        Server memory server = findServerById(_serverId);

        // server channels
        ServerChannel memory serverChannel;
        serverChannel.server = server;
        serverChannel.channel = channel;
        serverChannel.createdAt = channel.createdAt;

        channels.push(channel);
        serverChannels.push(serverChannel);
        return channel;
    }

    function joinServer(string memory _username, bytes32 _serverId)
    // serverExists(_serverId) requireUniqueUserAddress(msg.sender) requireUniqueUsername(_username)
    public returns(ServerUser memory) {
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
        serverUser.server = findServerById(_serverId);
        serverUser.createdAt = user.createdAt;

        // save to the blockchain
        users.push(user);
        serverUsers.push(serverUser);

        return serverUser;
    }

    function joinChannel(bytes32 _serverId, bytes32 _channelId)
        // serverExists(_serverId) channelExists(_channelId) userExists(_userAddress)
        // channelExistsInServer(_serverId, _channelId)
        public returns(ServerChannelUser memory) {
        // require that user is not already a member of the channel to prevent
        // duplicates
        // ServerChannelUser memory channelUser = findUserInChannel(_channelId, _userAddress);
        // require(channelUser.channel.id == "" && channelUser.user.id == "", "the user is already a member of this channel");

        // require that user is already a member of the server
        // ServerUser memory serverUser = findUserInServer(_serverId, _userAddress);
        // require(serverUser.server.id != "" && serverUser.user.id != "", "user must already be a member of the server");

        ServerChannelUser memory channelUser;
        channelUser.createdAt = block.timestamp;
        channelUser.serverId = _serverId;
        channelUser.channelId = _channelId;
        channelUser.user = msg.sender;

        serverChannelUsers.push(channelUser);

        return channelUser;
    }

    function sendMessage(bytes32 _serverId, bytes32 _channelId, string memory _message) public returns(Message memory) {
        Message memory message;
        message.createdAt = block.timestamp;
        message.id = bytes32(
            keccak256(
                abi.encodePacked(_serverId, _channelId, _message, msg.sender, message.createdAt)
            )
        );

        message.message = _message;
        message.serverId = _serverId;
        message.channelId = _channelId;
        message.createdBy = msg.sender;

        messages.push(message);

        return message;
    }


    function getServers() public view returns(Server[] memory) {
        return servers;
    }

    function findServerById(bytes32 id) public view returns(Server memory) {
        Server memory server;
        for(uint i = 0; i < servers.length; i++) {
            if(servers[i].id == id) {
                server = servers[i];
                break;
            }
        }

        return server;
    }

    function getChannels() public view returns(Channel[] memory) {
        return channels;
    }

    function getMessages() public view returns(Message[] memory) {
        return messages;
    }

    function findChannelById(bytes32 id) public view returns(Channel memory) {
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

    function getServerChannels() public view returns(ServerChannel[] memory) {
        return serverChannels;
    }

    function getChannelUsers() public view returns(ServerChannelUser[] memory) {
        return serverChannelUsers;
    }

    function findChannelInServer(bytes32 _serverId, bytes32 _channelId) public view returns(ServerChannel memory) {
        ServerChannel memory serverChannel;
        for(uint i = 0; i < serverChannels.length; i++) {
            if(serverChannels[i].server.id == _serverId && serverChannels[i].channel.id == _channelId) {
                serverChannel = serverChannels[i];
            }
        }

        return serverChannel;
    }

    function findUserInChannel(bytes32 _channelId, address _address) public view returns(ServerChannelUser memory) {
        ServerChannelUser memory channelUser;
        for(uint i = 0; i < serverChannelUsers.length; i++) {
            if(serverChannelUsers[i].channelId == _channelId && serverChannelUsers[i].user == _address) {
                channelUser = serverChannelUsers[i];
            }
        }

        return channelUser;
    }

    function findUserInServer(bytes32 _serverId, address _address) public view returns(ServerUser memory) {
        ServerUser memory serverUser;
        for(uint i = 0; i < serverUsers.length; i++) {
            if(serverUsers[i].server.id == _serverId && serverUsers[i].user.userAddress == _address) {
                serverUser = serverUsers[i];
            }
        }

        return serverUser;
    }
}
