const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
    // Setup provider dan wallet
    const provider = new ethers.JsonRpcProvider("https://testnet-rpc.monad.xyz/");
    const privateKey = process.env.PRIVATE_KEY;
    const wallet = new ethers.Wallet(privateKey, provider);
    console.log("Menggunakan akun:", wallet.address);

    // Load artifact kontrak
    const artifact = require("../artifacts/contracts/WaifuBattleArena.sol/WaifuBattleArena.json");
    const contractAddress = "0xCeb07861581AfFd76D0B866764dd62428b1A9e41";
    const contract = new ethers.Contract(contractAddress, artifact.abi, wallet);

    // Cek owner kontrak
    const owner = await contract.owner();
    console.log("Owner kontrak:", owner);
    if (owner.toLowerCase() !== wallet.address.toLowerCase()) {
        console.error("Akun ini bukan owner kontrak! Hanya owner yang bisa withdraw.");
        return;
    }

    // Cek saldo kontrak
    const contractBalance = await provider.getBalance(contractAddress);
    console.log("Saldo kontrak sebelum withdraw:", ethers.formatEther(contractBalance), "MON");

    // Panggil fungsi withdraw
    try {
        const feeData = await provider.getFeeData();
        const gasPrice = feeData.gasPrice;
        console.log("Gas price:", ethers.formatUnits(gasPrice, "gwei"), "Gwei");

        const estimatedGas = await contract.withdraw.estimateGas();
        console.log("Estimated gas:", estimatedGas.toString());

        const gasLimit = (estimatedGas * 120n) / 100n; // Buffer 20%
        console.log("Gas limit (with 20% buffer):", gasLimit.toString());

        const tx = await contract.withdraw({
            gasLimit: gasLimit,
            gasPrice: gasPrice
        });
        console.log("Mengirim transaksi withdraw...");
        const receipt = await tx.wait();
        console.log("Transaksi selesai, tx hash:", receipt.hash);

        // Hitung gas fee
        const gasUsed = receipt.gasUsed;
        const gasFee = gasUsed * gasPrice;
        console.log("Gas used:", gasUsed.toString());
        console.log("Gas fee:", ethers.formatEther(gasFee), "MON");

        // Cek saldo kontrak setelah withdraw
        const contractBalanceAfter = await provider.getBalance(contractAddress);
        console.log("Saldo kontrak setelah withdraw:", ethers.formatEther(contractBalanceAfter), "MON");

        // Cek saldo owner setelah withdraw
        const ownerBalanceAfter = await provider.getBalance(wallet.address);
        console.log("Saldo owner setelah withdraw:", ethers.formatEther(ownerBalanceAfter), "MON");
    } catch (error) {
        console.error("Error saat withdraw:", error);
        if (error.data) {
            const decodedError = contract.interface.parseError(error.data);
            console.log("Decoded error:", decodedError);
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("Error:", error);
        process.exit(1);
    });
