import {ethers} from "ethers";
const config = require("../config.json");
const abi = require("../abis/Disscord.json");

export const loadBlockchain = async () => {
    try {
        const { ethereum } = window;
        if (!ethereum) {
            console.log("Cannot connect to the blockchain because you don't have a wallet installed.");
            return {};
        }

        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const network = await provider.getNetwork();
        const amazonContract = new ethers.Contract(
            config[network.chainId].amazon.address,
            abi.abi,
            provider
        );

        return {provider, signer, network, amazonContract}
    } catch (error) {
        console.log("Error connecting to the blockchain: ", error);
        return {};
    }
}
