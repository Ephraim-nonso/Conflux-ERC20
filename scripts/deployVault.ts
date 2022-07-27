import {abi, bytecode} from "../artifacts/contracts/Vault.sol/Vault.json";
import { Conflux, Drip } from 'js-conflux-sdk'

const testnet = "https://test.confluxrpc.com"
const witnet = "cfxtest:aceh1wg5t0jyctjzsydvwktsvz596nf6ue18kkzpp3"
const tokenAddress = "cfxtest:acf00puuhggcdy2t4ywzruyr5n2f74yvs6psxamfrj"
const recipientAddr = "cfxtest:aarthy7b74x09687hxpe7fzs2kt0k3see2xcevy55r"

async function deployVault () {
    // Create an instance of Conflux testnet
    const conflux  = new Conflux({
        url: testnet,
        networkId: 1,
        logger: console,
      })

    // Establish wallet to make deployment.
    const wallet = conflux.wallet.addPrivateKey(process.env.CONFLUX_PRIVATE_KEY)

    // Create instance for the contract to be deployed using the abi and bytecode
    const contractInstance = conflux.Contract({abi, bytecode})

    // Deploy contract and generate contract address
    const deploytx = await contractInstance.constructor(witnet).sendTransaction({from: wallet, value: Drip.fromCFX(4),}).executed()

    console.log("Contractaddress is", deploytx.contractCreated)
    console.log("Deployed vault tx is", deploytx.transactionHash)

  // Create instance with abi and contract address
  const createGrant = conflux.Contract({ abi, address: deploytx.contractCreated })

  //call the createGrant function
  const tx = await createGrant
    //@ts-ignore
    .createGrantFund(tokenAddress, recipientAddr, "2000", "1659954869")
    .sendTransaction({ from: wallet.toString() })
  console.log('Create grants', wallet.toString(), 'in txn ', tx)
}

deployVault().catch((error) => {
    console.error(error);
    process.exitCode = 1
})