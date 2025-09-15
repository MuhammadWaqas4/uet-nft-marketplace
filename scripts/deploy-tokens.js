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
    const ownerAddress = "0x82389495Bb548E00e901F8AC82E9761152898834";
    const usdt = "0xc67ab320Df41D8589Cae74B69F45eb2EC09104fC";
    // const rewardWalletAddress = process.env.REWARD_WALLET_ADDRESS;
    // const totalSupply = process.env.TOTAL_SUPPLY;

    // Deploying token.
    let string1 = "Bored Ape";
    let string2 = "Ape";
    // let deployedAddress = await deploy("ProFactory", []);

    // const instance= await hre.ethers.getContractAt("ProFactory","0xd0BEC95C7CA4Df8De24Be3B793250Fa3939076e8") 
    // console.log({instance});

    // const deployed= await instance.createPro(string1,string2);
    // await new Promise((resolve) => setTimeout(resolve, 20000));

    // console.log(deployed);
    // console.log(deployed.event.newPro);
     await verify('0x56C23caE236FDeE535D7a8498C54C6c2b6049f5c', [string1,string2]);
    return
    
    // let deployedAddress = "0xD7f1D29D75e2b363f559f3a663f9A8e7D7B73C77"

    // Setting environment variables
    // parsedENVFile.deployedAddress = deployedAddress;
    // fs.writeFileSync(".env", envfile.stringify(parsedENVFile));
    console.log("deployedAddress", deployedAddress);

    // Waiting for block explorer.
    // await new Promise((resolve) => setTimeout(resolve, 20000));

    // Verifying token.
    // await verify(deployedAddress, [ownerAddress, rewardWalletAddress, totalSupply]);
    await verify(deployedAddress, []);
        return

    // Exiting.
    // process.exit();
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
