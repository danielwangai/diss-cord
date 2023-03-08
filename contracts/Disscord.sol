// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Disscord {
    struct Server {
        bytes32 id;
        string name;
        string about;
        address payable owner;
        uint256 createdAt;
    }

    Server[] public servers;

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
        server.owner = payable(msg.sender);

        servers.push(server);
        return server;
    }

    function getServers() public view returns(Server[] memory) {
        return servers;
    }

    function getServer(bytes32 id) public view returns(Server memory) {
        Server memory server;
        for(uint i = 0; i < servers.length; i++) {
            if(servers[i].id == id) {
                server = servers[i];
            }
        }

        return server;
    }
}
