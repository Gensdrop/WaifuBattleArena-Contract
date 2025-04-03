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

    // Cek waifuCount sebelum buat waifu
    const waifuCountBefore = await contract.waifuCount();
    console.log("waifuCount sebelum:", waifuCountBefore.toString());

    // Parameter untuk createWaifu
    const role = 0; // Attacker
    const tier = 1; // Tier 1
    const personality = 0; // Aggressive
    console.log(`Membuat waifu dengan role: ${role}, tier: ${tier}, personality: ${personality}`);

    // Hitung biaya (pake BigInt langsung)
    const baseCost = ethers.parseEther("0.1") * BigInt(tier + 1);
    const roleCost = role === 4 ? ethers.parseEther("0.05") : ethers.parseEther("0.02");
    const personalityCost = personality === 4 ? ethers.parseEther("0.03") : ethers.parseEther("0");
    const totalCost = baseCost + roleCost + personalityCost;
    console.log("Total biaya untuk createWaifu:", ethers.formatEther(totalCost), "MON");

    // Panggil createWaifu
    try {
        const feeData = await provider.getFeeData();
        const gasPrice = feeData.gasPrice;
        console.log("Gas price:", ethers.formatUnits(gasPrice, "gwei"), "Gwei");

        const estimatedGas = await contract.createWaifu.estimateGas(role, tier, personality, {
            value: totalCost
        });
        console.log("Estimated gas:", estimatedGas.toString());

        const gasLimit = (estimatedGas * 120n) / 100n; // Buffer 20%
        console.log("Gas limit (with 20% buffer):", gasLimit.toString());

        const tx = await contract.createWaifu(role, tier, personality, {
            value: totalCost,
            gasLimit: gasLimit,
            gasPrice: gasPrice
        });
        console.log("Mengirim transaksi createWaifu...");
        const receipt = await tx.wait();
        console.log("Waifu berhasil dibuat, tx hash:", receipt.hash);

        // Hitung gas fee
        const gasUsed = receipt.gasUsed;
        const gasFee = gasUsed * gasPrice;
        console.log("Gas used:", gasUsed.toString());
        console.log("Gas fee:", ethers.formatEther(gasFee), "MON");

        // Cek waifuCount setelah buat waifu
        const waifuCountAfter = await contract.waifuCount();
        console.log("waifuCount setelah:", waifuCountAfter.toString());

        // Cek data waifu yang baru dibuat
        const waifuId = waifuCountBefore; // Waifu ID baru = waifuCount sebelumnya
        const waifu = await contract.waifus(waifuId);
        console.log("Data waifu yang baru dibuat:", {
            id: waifu[0].toString(),
            owner: waifu[1],
            role: waifu[2].toString(),
            tier: waifu[3].toString(),
            personality: waifu[4].toString(),
            attack: waifu[5].toString(),
            defense: waifu[6].toString(),
            speed: waifu[7].toString(),
            hp: waifu[8].toString(),
            stamina: waifu[9].toString(),
            exp: waifu[10].toString(),
            skills: waifu[11].map(s => s.toString()),
            traits: waifu[12].map(t => t.toString()),
            cooldowns: waifu[13].map(c => c.toString()),
            modifiers: waifu[14].map(m => m.toString()),
            questProgress: waifu[15].map(q => q.toString()),
            items: waifu[16].map(i => i.toString()),
            isFused: waifu[17],
            lastBattleTimestamp: waifu[18].toString(),
            trainingCount: waifu[19].toString(),
            roleSynergyBonus: waifu[20].map(r => r.toString()),
            personalityBoost: waifu[21].toString(),
            battleHistory: waifu[22].map(b => b.toString()),
            itemTypeBoosts: waifu[23].map(i => i.toString()),
            lastRestTimestamp: waifu[24].toString()
        });
    } catch (error) {
        console.error("Error saat createWaifu:", error);
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
