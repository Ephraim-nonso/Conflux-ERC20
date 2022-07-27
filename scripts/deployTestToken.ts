import {abi, bytecode} from "../artifacts/contracts/TestToken.sol/TestToken.json";
import { Conflux } from 'js-conflux-sdk'

const testnet = "https://test.confluxrpc.com"

async function deployTestToken () {
    // Create an instance of Conflux testnet
    const conflux  = new Conflux({
        url: testnet,
        networkId: 1,
        logger: console,
      })

    // Establish wallet to make deployment.
    const wallet = conflux.wallet.addPrivateKey(process.env.CONFLUX_PRIVATE_KEY)

    // Create instance for the contract to be deployed
    const contractInstance = conflux.Contract({abi, bytecode})

    // Deploy contract and generate contract address
    const deploytx = await contractInstance.constructor().sendTransaction({from: wallet}).executed()

    console.log("Contractaddress is", deploytx.contractCreated)
    console.log("Deployed token tx is", deploytx.transactionHash)
}

deployTestToken().catch((error) => {
    console.error(error);
    process.exitCode = 1
})