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

    // Cek owner
    const owner = await contract.owner();
    console.log("Owner kontrak:", owner);

    // Cek waifuCount sebelum
    const waifuCountBefore = await contract.waifuCount();
    console.log("waifuCount sebelum:", waifuCountBefore.toString());

    // Test createWaifu
    const role = 0; // Attacker
    const tier = 1; // Tier 1
    const personality = 0; // Aggressive
    const cost = ethers.parseEther("0.22"); // Fix: 0.1 * (1+1) + 0.02 = 0.22 ETH
    console.log("Membuat waifu baru dengan cost:", ethers.formatEther(cost), "ETH");
    try {
        const tx = await contract.createWaifu(role, tier, personality, {
            value: cost,
            gasLimit: 5000000
        });
        const receipt = await tx.wait();
        console.log("Waifu dibuat, tx hash:", receipt.hash);
    } catch (error) {
        console.error("Error createWaifu:", error);
        if (error.data) {
            const decodedError = contract.interface.parseError(error.data);
            console.log("Decoded error:", decodedError);
        }
    }

    // Cek waifuCount sesudah
    const waifuCountAfter = await contract.waifuCount();
    console.log("waifuCount sesudah:", waifuCountAfter.toString());

    // Cek data waifu
    const waifuId = waifuCountBefore;
    const waifu = await contract.waifus(waifuId);
    console.log("Data waifu:", {
        id: waifu.id.toString(),
        owner: waifu.owner,
        role: waifu.role.toString(),
        tier: waifu.tier.toString(),
        personality: waifu.personality.toString(),
        attack: waifu.attack.toString(),
        defense: waifu.defense.toString(),
        speed: waifu.speed.toString(),
        hp: waifu.hp.toString(),
        stamina: waifu.stamina.toString()
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("Error:", error);
        process.exit(1);
    });
