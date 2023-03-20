import { loadBlockchain } from "./loadBlockchain";

export const signUp = async (username) => {
    try {
        let { signer, contract } = await loadBlockchain();
        const transaction = await contract.connect(signer).joinServer(username);
        await transaction.wait();
    } catch (error) {
        console.log("An error occurred when adding signing up: ", error);
        throw error;
    }
}
