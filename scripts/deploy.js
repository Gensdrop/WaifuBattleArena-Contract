const { ethers } = require("ethers");                                      const fs = require("fs");                                                  const path = require("path");                                              require("dotenv").config();                                                const hre = require("hardhat");

async function main() {
    const privateKey = process.env.PRIVATE_KEY;
    console.log("Private key dari .env:", privateKey);
    if (!privateKey || !privateKey.startsWith("0x") || privateKey.length !== 66) {
        throw new Error("Private key ga valid! Cek .env, harus 64 hex chars mulai 0x.");
    }
                                                                               const provider = new ethers.JsonRpcProvider("https://testnet-rpc.monad.xyz/");
    const deployer = new ethers.Wallet(privateKey, provider);
    console.log("Deploy pake akun:", deployer.address);

    const balance = await provider.getBalance(deployer.address);
    console.log("Saldo akun sebelum deploy:", ethers.formatEther(balance), "MON");

    const artifactPath = path.resolve(__dirname, "../artifacts/contracts/WaifuBattleArena.sol/WaifuBattleArena.json");
    const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));
    const bytecode = artifact.bytecode;
    console.log("Ukuran initcode:", bytecode.length / 2, "bytes");

    console.log("Lagi deploy WaifuBattleArena...");
    const tx = {
        data: bytecode,
        gasLimit: 30000000
    };
    const txResponse = await deployer.sendTransaction(tx);
    const receipt = await txResponse.wait();
    const contractAddress = receipt.contractAddress;
    console.log("WaifuBattleArena berhasil deploy ke:", contractAddress);

    console.log("Mulai verifikasi kontrak...");
    try {
        await hre.run("verify:verify", {
            address: contractAddress,
            constructorArguments: [],
            network: "monad"
        });
        console.log("Kontrak berhasil diverifikasi di Monad Explorer!");
    } catch (error) {
        console.log("Verifikasi gagal:", error.message);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("Error:", error);
        process.exit(1);
    });
