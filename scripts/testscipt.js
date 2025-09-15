const privateKey = "0x46b56f07bd80c6ca1f9416bd737e315a0d15e346ebd7c14c39f782e390f58f82"; // DO NOT use a real wallet on mainnet
const hre = require("hardhat");
const { ethers } = hre;
async function main() {

    // Replace with your actual addresses and parameters
    const contractAddress = "0xa3A518Ba4e193Fb129aa379F5916d4660f15cE5D";
    const platformFeeRecipient = "0x30254A18d89ad9A91C97C06cA37BdCb85B013EB2";
    const sellerAddress = "0x30254A18d89ad9A91C97C06cA37BdCb85B013EB2";
    const sellerSigner = await ethers.getSigner(sellerAddress);

    const price = ethers.parseEther("1.0"); // 1 ETH
    const offerTime = Math.floor(Date.now() / 1000);
    const tokenId = 1;

    console.log("Seller data:", contractAddress, sellerSigner, price, offerTime, tokenId);

    // Solidity equivalent:
    // keccak256(abi.encodePacked(this, values._seller, values._price, offerTime, values.tokenId))
    const hash = ethers.solidityPackedKeccak256(
      ["address", "uint256", "uint256", "uint256"],
      [sellerAddress, price, offerTime, tokenId]
    );
    // [ sellerAddress, 1000, 1751187839, 213]

    console.log("hash:",hash);

    // Sign the hash
    const signature = await sellerSigner.signMessage(ethers.getBytes(hash));
    console.log("signature:",signature);

    const ethSignedHash = ethers.hashMessage(hash);
    const receoverdaddress = ethers.verifyMessage(hash,signature);
    console.log("ethSignedHash:",ethSignedHash, "receoverdaddress::", receoverdaddress);

    console.log("---- Seller Signature Details ----");
    console.log("Contract Address :", contractAddress);
    console.log("Seller Address   :", sellerAddress);
    console.log("Price            :", price.toString());
    console.log("Offer Time       :", offerTime);
    console.log("Token ID         :", tokenId);
    console.log("Message Hash     :", hash);
    console.log("Eth-Signed Hash  :", ethSignedHash);
    console.log("Signature        :", signature);
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });