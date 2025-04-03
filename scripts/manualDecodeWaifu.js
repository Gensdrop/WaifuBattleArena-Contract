const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
    const provider = new ethers.JsonRpcProvider("https://testnet-rpc.monad.xyz/");
    const privateKey = process.env.PRIVATE_KEY;
    const wallet = new ethers.Wallet(privateKey, provider);
    console.log("Menggunakan akun:", wallet.address);

    const contractAddress = "0xCeb07861581AfFd76D0B866764dd62428b1A9e41";
    const contract = new ethers.Contract(contractAddress, [
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "name": "waifus",
            "outputs": [
                {
                    "components": [
                        {"internalType": "uint256", "name": "id", "type": "uint256"},
                        {"internalType": "address", "name": "owner", "type": "address"},
                        {"internalType": "uint8", "name": "role", "type": "uint8"},
                        {"internalType": "uint8", "name": "tier", "type": "uint8"},
                        {"internalType": "uint8", "name": "personality", "type": "uint8"},
                        {"internalType": "uint256", "name": "attack", "type": "uint256"},
                        {"internalType": "uint256", "name": "defense", "type": "uint256"},
                        {"internalType": "uint256", "name": "speed", "type": "uint256"},
                        {"internalType": "uint256", "name": "hp", "type": "uint256"},
                        {"internalType": "uint256", "name": "stamina", "type": "uint256"},
                        {"internalType": "uint256", "name": "exp", "type": "uint256"},
                        {"internalType": "uint256[3]", "name": "skills", "type": "uint256[3]"},
                        {"internalType": "uint256[3]", "name": "traits", "type": "uint256[3]"},
                        {"internalType": "uint256[3]", "name": "cooldowns", "type": "uint256[3]"},
                        {"internalType": "uint256[3]", "name": "modifiers", "type": "uint256[3]"},
                        {"internalType": "uint256[5]", "name": "questProgress", "type": "uint256[5]"},
                        {"internalType": "uint256[]", "name": "items", "type": "uint256[]"},
                        {"internalType": "bool", "name": "isFused", "type": "bool"},
                        {"internalType": "uint256", "name": "lastBattleTimestamp", "type": "uint256"},
                        {"internalType": "uint256", "name": "trainingCount", "type": "uint256"},
                        {"internalType": "uint256[5]", "name": "roleSynergyBonus", "type": "uint256[5]"},
                        {"internalType": "uint256", "name": "personalityBoost", "type": "uint256"},
                        {"internalType": "uint256[5]", "name": "battleHistory", "type": "uint256[5]"},
                        {"internalType": "uint256[4]", "name": "itemTypeBoosts", "type": "uint256[4]"},
                        {"internalType": "uint256", "name": "lastRestTimestamp", "type": "uint256"}
                    ],
                    "internalType": "struct WaifuBattleArena.Waifu",
                    "name": "",
                    "type": "tuple"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        }
    ], wallet);

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
