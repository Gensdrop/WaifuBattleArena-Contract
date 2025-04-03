const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
  const provider = new ethers.JsonRpcProvider("https://testnet-rpc.monad.xyz/");
  const contractAddress = "0x07df3902dcD3Af1c39b505ED3F1B0255C67fb09b";
  const abi = [
    "function createWaifu(uint8 role, uint8 tier, uint8 personality) payable",
    "function waifus(uint256) view returns (uint256, address, uint8, uint8, uint8, uint256, uint256, uint256, uint256, uint256, uint256, uint256[3], uint256[3], uint256[3], uint256[3], uint256[5], uint256[], bool, uint256, uint256, uint256[5], uint256, uint256[5], uint256[4], uint256)"
  ];
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const contract = new ethers.Contract(contractAddress, abi, wallet);

  console.log("Create Waifu...");
  const tx = await contract.createWaifu(0, 0, 0, { value: ethers.parseEther("0.12") });
  await tx.wait();

  console.log("Cek waifus[0]...");
  const waifu = await contract.waifus(0);
  console.log("Waifu Data:", waifu);
  console.log("Field Count:", waifu.length);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error:", error);
    process.exit(1);
  });
