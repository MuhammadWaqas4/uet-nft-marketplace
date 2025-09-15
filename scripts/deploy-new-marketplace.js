const hre = require("hardhat");

const envfile = require("envfile");
const fs = require("fs");
const parsedENVFile = envfile.parse(fs.readFileSync(".env"));

async function main() {
    // Checking gas price.
    const gasPriceUpperBound = process.env.GAS_PRICE_UPPER_BOUND;
    await checkGasPrice(gasPriceUpperBound);

    // Getting network name.
    console.log("Chain:", hre.network.name);

    // Deployment variables.
    const ownerAddress = process.env.OWNER_ADDRESS;
    const platformFeeRecipient = "0x30254A18d89ad9A91C97C06cA37BdCb85B013EB2";

    // Deploying token.
    const marketplace3Address = await deploy("UETMarketplace", [platformFeeRecipient]);
    // const marketplace3Address = "0x9F4257bE52D88d4F8E24C513834BE71B757858d1"
    // const marketplace3Address = "0x01a93b7153Ee160F3176af0B0F31121DF9f0FFA5";
    // Setting environment variables
    // fs.writeFileSync(".env", envfile.stringify(parsedENVFile));

    console.log("marketplace3Address", marketplace3Address);

    // // Waiting for block explorer.
    await new Promise((resolve) => setTimeout(resolve, 60000));

    // Verifying token.
    await verify(marketplace3Address, [platformFeeRecipient]);

    // Exiting.
    process.exit();
}

async function checkGasPrice(gasPriceUpperBound) {
    let feeData = await hre.ethers.provider.getFeeData();
    let gasPrice = parseFloat(hre.ethers.formatUnits(feeData.gasPrice, "gwei"));
    console.log("Gas Price:", gasPrice, "Gwei");

    if (gasPriceUpperBound != "" && gasPriceUpperBound != "0") {
        while (gasPrice > gasPriceUpperBound) {
            feeData = await hre.ethers.provider.getFeeData();

            if (gasPrice != hre.ethers.formatUnits(feeData.gasPrice, "gwei")) {
                gasPrice = parseFloat(hre.ethers.formatUnits(feeData.gasPrice, "gwei"));
                console.log("Gas Price:", gasPrice, "Gwei");
            }
        }
    }
}

async function deploy(contractName, constructorArguments) {
    const contract = await hre.ethers.deployContract(contractName, constructorArguments);
    console.log(`${contract} deployed to:`);
    await contract.waitForDeployment();

    const contractAddress = contract.target;
    const deploymentTxHash = await contract.deploymentTransaction().hash;
    const deploymentTx = await hre.ethers.provider.getTransactionReceipt(deploymentTxHash);
    const deploymentBlockNumber = deploymentTx.blockNumber;

    console.log(`${contractName} deployed to:`, contractAddress);
    console.log("at block number:", deploymentBlockNumber);

    return contractAddress;
}

async function verify(contractAddress, constructorArguments) {
    console.log(`verify ${contractAddress} with arguments ${constructorArguments.join(",")}`);

    try {
        await hre.run("verify:verify", { address: contractAddress, constructorArguments: constructorArguments });
    } catch (error) {
        console.log(error);
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
    process.exit();
});
