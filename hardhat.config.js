require("@nomicfoundation/hardhat-foundry");
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.8.28",
                settings: {
                    viaIR:true,
                    optimizer: {
                        enabled: true,
                        runs: 999999
                    }
                }
            }
        ]
    },
    defaultNetwork: "mainnet",
    networks: {
        hardhat: {
            forking: {
                url: process.env.URL_STAGING
            }
        },
        staging: {
            url: process.env.URL_STAGING ? process.env.URL_STAGING : "https://place.holder",
            accounts: [
                process.env.PRIVATE_KEY_STAGING
                    ? process.env.PRIVATE_KEY_STAGING
                    : "0x0000000000000000000000000000000000000000000000000000000000000000"
            ]
        },
        mainnet: {
            url: process.env.URL_MAINNET ? process.env.URL_MAINNET : "https://place.holder",
            accounts: [
                process.env.PRIVATE_KEY_MAINNET
                    ? process.env.PRIVATE_KEY_MAINNET
                    : "0x0000000000000000000000000000000000000000000000000000000000000000"
            ]
        }
    },
    etherscan: {
        apiKey: {
            holesky: process.env.BLOCK_EXPLORER_API_KEY_STAGING,
            sepolia: process.env.BLOCK_EXPLORER_API_KEY_ETHEREUM,
            bsc: process.env.BLOCK_EXPLORER_API_KEY_BSC
        }
    }
};
