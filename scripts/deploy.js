const hre = require("hardhat");

async function main() {
    // Checking gas price.
    const gasPriceUpperBound = process.env.GAS_PRICE_UPPER_BOUND;
    await checkGasPrice(gasPriceUpperBound);

    // Getting network name.
    const networkName = hre.network.name;
    console.log("Chain:", networkName);

    // Deployment variables.
    const ownerAddress = process.env.OWNER_ADDRESS;
    const name = process.env.NAME;
    const symbol = process.env.SYMBOL;
    const cap = process.env.CAP;
    const treasuryWalletAddress = process.env.TREASURY_WALLET_ADDRESS;
    const rewardWalletAddress = process.env.REWARD_WALLET_ADDRESS;
    const pai3Address = process.env.PAI3_ADDRESS;
    const signerAddress = process.env.SIGNER_ADDRESS;
    const baseURI = process.env.BASE_URI;
    const situationalCaps = process.env.SITUATIONAL_CAPS.split("|");
    const saleBaseCosts = process.env.SALE_BASE_COSTS.split("|");
    const phaseBaseCosts = process.env.PHASE_BASE_COSTS.split("|");
    let windows = process.env.WINDOWS.split("|");
    const tokenAddresses = process.env.TOKEN_ADDRESSES.split("|");
    const priceFeedAddresses = process.env.PRICE_FEED_ADDRESSES.split("|");

    // Structuring deployment variables.
    windows = windows.map((value) => {
        const splitValue = value.split("~");

        const result = {
            startTimestamp: splitValue[0],
            endTimestamp: splitValue[1]
        };

        return result;
    });
    const pai3NodeParams = {
        owner: ownerAddress,
        name: name,
        symbol: symbol,
        cap: cap,
        treasuryWallet: treasuryWalletAddress,
        rewardWallet: rewardWalletAddress,
        pai3: pai3Address,
        signer: signerAddress,
        baseURI: baseURI,
        situationalCaps: situationalCaps,
        saleBaseCosts: saleBaseCosts,
        phaseBaseCosts: phaseBaseCosts,
        windows: windows,
        tokens: tokenAddresses,
        priceFeeds: priceFeedAddresses
    };

    // Deploying collections.
    const pai3NodeAddress = await deploy("PAI3Node", [pai3NodeParams]);

    // Setting up collections.
    if (networkName === "staging" || networkName === "hardhat") {
        const pai3Instance = await hre.ethers.getContractAt("PAI3", pai3Address);

        const approvalTransaction = await pai3Instance.approve(pai3NodeAddress, BigInt(2 ** 256) - 1n);
        await approvalTransaction.wait(1);

        console.log("PAI3 approved for PAI3Node");

        const pai3NodeInstance = await hre.ethers.getContractAt("PAI3Node", pai3NodeAddress);

        const updateTransaction = await pai3NodeInstance.updateClaimable(true);
        await updateTransaction.wait(1);

        console.log("PAI3Node claims opened");
    }

    // Waiting for block explorer.
    await new Promise((resolve) => setTimeout(resolve, 60000));

    // Verifying collections.
    await verify(pai3NodeAddress, [pai3NodeParams]);

    // Exiting.
    process.exit();
}

async function checkGasPrice(gasPriceUpperBound) {
    let feeData = await hre.ethers.provider.getFeeData();
    let gasPrice = parseFloat(hre.ethers.formatUnits(feeData.gasPrice, "gwei"));

    console.log(`Gas Price: ${gasPrice} Gwei`);

    if (gasPriceUpperBound != "" && gasPriceUpperBound != "0") {
        while (gasPrice > gasPriceUpperBound) {
            feeData = await hre.ethers.provider.getFeeData();

            if (gasPrice != hre.ethers.formatUnits(feeData.gasPrice, "gwei")) {
                gasPrice = parseFloat(hre.ethers.formatUnits(feeData.gasPrice, "gwei"));

                console.log(`Gas Price: ${gasPrice} Gwei`);
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

async function verifyWithPath(contractAddress, contractPath, constructorArguments) {
    console.log(`verify ${contractAddress} with arguments ${constructorArguments.join(",")}`);

    try {
        await hre.run("verify:verify", {
            address: contractAddress,
            contract: contractPath,
            constructorArguments: constructorArguments
        });
    } catch (error) {
        console.log(error);
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
    process.exit();
});
