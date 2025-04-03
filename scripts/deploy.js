const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");
require("dotenv").config();
const hre = require("hardhat");

async function main() {
    const privateKey = process.env.PRIVATE_KEY;
    console.log("Private key from .env:", privateKey);
    if (!privateKey || !privateKey.startsWith("0x") || privateKey.length !== 66) {
        throw new Error("Invalid private key! Check .env, must be 64 hex chars starting with 0x.");
    }

    const provider = new ethers.JsonRpcProvider("https://testnet-rpc.monad.xyz/");
    const deployer = new ethers.Wallet(privateKey, provider);
    console.log("Deploying using account:", deployer.address);

    const balance = await provider.getBalance(deployer.address);
    console.log("Account balance before deploy:", ethers.formatEther(balance), "MON");

    const artifactPath = path.resolve(__dirname, "../artifacts/contracts/WaifuBattleArena.sol/WaifuBattleArena.json");
    const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));
    const bytecode = artifact.bytecode;
    console.log("Initcode size:", bytecode.length / 2, "bytes");

    console.log("Deploying WaifuBattleArena...");
    const tx = {
        data: bytecode,
        gasLimit: 30000000
    };
    const txResponse = await deployer.sendTransaction(tx);
    const receipt = await txResponse.wait();
    const contractAddress = receipt.contractAddress;
    console.log("WaifuBattleArena successfully deployed to:", contractAddress);

    console.log("Starting contract verification...");
    try {
        await hre.run("verify:verify", {
            address: contractAddress,
            constructorArguments: [],
            network: "monad"
        });
        console.log("Contract successfully verified on Monad Explorer!");
    } catch (error) {
        console.log("Verification failed:", error.message);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("Error:", error);
        process.exit(1);
    });
