export const isWalletConnected = async () => {
    let account = "";
    try {
        const { ethereum } = window;

        const accounts = await ethereum.request({method: 'eth_accounts'})

        if (accounts.length > 0) {
            account = accounts[0];
            console.log("wallet is connected! " + account);
        } else {
            console.log("make sure MetaMask is connected");
        }
        return account;
    } catch (error) {
        console.log("error: ", error);
        return account;
    }
}
