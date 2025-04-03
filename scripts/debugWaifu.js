const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
    const provider = new ethers.JsonRpcProvider("https://testnet-rpc.monad.xyz/");
    const privateKey = process.env.PRIVATE_KEY;
    const wallet = new ethers.Wallet(privateKey, provider);
    console.log("Menggunakan akun:", wallet.address);

    const artifact = require("../artifacts/contracts/WaifuBattleArena.sol/WaifuBattleArena.json");
    const contractAddress = "0xCeb07861581AfFd76D0B866764dd62428b1A9e41";
    const contract = new ethers.Contract(contractAddress, artifact.abi, wallet);

    const waifuId = 0;
    const waifu = await contract.waifus(waifuId);
    console.log("Raw data waifu:", waifu);
    console.log("Jumlah field:", waifu.length);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("Error:", error);
        process.exit(1);
    });
