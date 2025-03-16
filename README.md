# PAI3

This repository includes the smart contracts, tests and scripts for the PAI3 ecosystem.

## How do I get set up?

Open a terminal in your workspace and then type in the following commands to fulfil the setup requirements:

1. `git clone https://github.com/pai3-protocol/pai3.git`
2. `cd pai3`
3. `npm i`

## Deployment

### Setup environment variables

Set the `URL_MAINNET` and `PRIVATE_KEY_MAINNET` as environment variables for mainnet deployment on your preferred mainnet or similarly `URL_STAGING` and `PRIVATE_KEY_STAGING` for staging deployment on your preferred testnet. `BLOCK_EXPLORER_API_KEY_<CHAIN>` must be set for each of the specific mainnet and testnet chains.<br>
You can achieve this by first creating a file named **.env** at the root of your project. Then copy the contents of the **.env.example** file into your newly created **.env** file. Finally fill in the variables for the aforementioned networks.

`URL_...`: This is the RPC URL of your chosen network. Most online resources can provide these for free.<br>
`PRIVATE_KEY_...`: This is the private key of your account<sup>1</sup>.<br>
`BLOCK_EXPLORER_API_KEY_...`: This is the block explorer api key used for verification of contracts. You can get these from your account on the relevant block explorer of your chosen network.

[1] **For staging deployment, please use a key that does NOT have any real funds associated with it.**

### Configure API keys

Set the etherscan api key in the **hardhat.config.js** file for the aforementioned networks.<br>
You can achieve this by matching the `BLOCK_EXPLORER_API_KEY_<CHAIN>` with the network identifier of each of the specific mainnet and testnet chains in your **hardhat.config.js** under `module.exports` > `etherscan` > `apiKey`.<br>
For instance, when using bsc mainnet for mainnet deployments, and sepolia and holesky testnet for staging deployments your `apiKey` object should look like this:

```
module.exports = {
    ...
    etherscan: {
        ...
        apiKey: {
            sepolia: process.env.BLOCK_EXPLORER_API_KEY_ETHEREUM,
            holesky: process.env.BLOCK_EXPLORER_API_KEY_ETHEREUM,
            bsc: process.env.BLOCK_EXPLORER_API_KEY_BSC
        }
    }
};
```

### Run the deployment script

For mainnet deployment, open a terminal at the root of your project then run the following command. This will deploy and setup all relevant contracts on your chosen mainnet:

`npm run deploy`

For staging deployment, run the following command. This will deploy and setup all relevant contracts on your chosen testnet:

`npm run deploy-staging`

## Test

Open a terminal at the root of your project. Then run the following command:

`npm run test`
