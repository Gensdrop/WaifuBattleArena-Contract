const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
    const provider = new ethers.JsonRpcProvider("https://testnet-rpc.monad.xyz/");
    const privateKey = process.env.PRIVATE_KEY;
    const wallet = new ethers.Wallet(privateKey, provider);
    console.log("Test pake akun:", wallet.address);

    const artifact = require("../artifacts/contracts/WaifuBattleArena.sol/WaifuBattleArena.json");
    const contractAddress = "0x1dCE4E4798Abc71D711A226A9430d8E8434a7989";
    const contract = new ethers.Contract(contractAddress, artifact.abi, wallet);

    // Cek owner kontrak
    const owner = await contract.owner();
    console.log("Owner kontrak:", owner);

    // Cek waifuCount
    const waifuCount = await contract.waifuCount();
    console.log("waifuCount:", waifuCount.toString());
    if (waifuCount == 0) {
        console.log("Belum ada waifu! Jalankan testWaifu.js dulu untuk bikin waifu.");
        return;
    }

    // Cek data waifu sebelum training
    const waifuId = 0; // Waifu ID 0
    let waifuBefore = await contract.waifus(waifuId);
    console.log("Data waifu sebelum training:", {
        id: waifuBefore[0].toString(),
        owner: waifuBefore[1],
        role: waifuBefore[2].toString(),
        tier: waifuBefore[3].toString(),
        personality: waifuBefore[4].toString(),
        attack: waifuBefore[5].toString(),
        defense: waifuBefore[6].toString(),
        speed: waifuBefore[7].toString(),
        hp: waifuBefore[8].toString(),
        stamina: waifuBefore[9].toString(),
        exp: waifuBefore[10].toString(),
        trainingCount: waifuBefore[18].toString(),
        personalityBoost: waifuBefore[20].toString(),
        cooldowns: [waifuBefore[12].toString(), waifuBefore[13].toString(), waifuBefore[14].toString()]
    });

    // Test trainAttacker
    console.log("Training waifu sebagai Attacker...");
    let txHash;
    try {
        const gasPrice = await provider.getGasPrice();
        console.log("Gas price:", ethers.formatUnits(gasPrice, "gwei"), "Gwei");

        const estimatedGas = await contract.trainAttacker.estimateGas(waifuId, {
            value: ethers.parseEther("0.02")
        });
        console.log("Estimated gas:", estimatedGas.toString());

        const gasLimit = estimatedGas * 120n / 100n; // Buffer 20%
        console.log("Gas limit (with 20% buffer):", gasLimit.toString());

        const tx = await contract.trainAttacker(waifuId, {
            value: ethers.parseEther("0.02"), // Cost 0.02 MON
            gasLimit: gasLimit,
            gasPrice: gasPrice
        });
        const receipt = await tx.wait();
        txHash = receipt.hash;
        console.log("Training selesai, tx hash:", txHash);

        // Hitung gas fee
        const gasUsed = receipt.gasUsed;
        const gasFee = gasUsed * gasPrice;
        console.log("Gas used:", gasUsed.toString());
        console.log("Gas fee:", ethers.formatEther(gasFee), "MON");
    } catch (error) {
        console.error("Error trainAttacker:", error);
        if (error.data) {
            const decodedError = contract.interface.parseError(error.data);
            console.log("Decoded error:", decodedError);
        }
        return;
    }

    // Tunggu sebentar biar state di blockchain update
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Fetch ulang data waifu sesudah training
    let waifuAfter = await contract.waifus(waifuId);
    console.log("Data waifu sesudah training:", {
        id: waifuAfter[0].toString(),
        owner: waifuAfter[1],
        role: waifuAfter[2].toString(),
        tier: waifuAfter[3].toString(),
        personality: waifuAfter[4].toString(),
        attack: waifuAfter[5].toString(),
        defense: waifuAfter[6].toString(),
        speed: waifuAfter[7].toString(),
        hp: waifuAfter[8].toString(),
        stamina: waifuAfter[9].toString(),
        exp: waifuAfter[10].toString(),
        trainingCount: waifuAfter[18].toString(),
        personalityBoost: waifuAfter[20].toString(),
        cooldowns: [waifuAfter[12].toString(), waifuAfter[13].toString(), waifuAfter[14].toString()]
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("Error:", error);
        process.exit(1);
    });
