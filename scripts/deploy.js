const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying with account:", deployer.address);

    const MyTokenWithDynamicFee = await hre.ethers.getContractFactory("MyTokenWithDynamicFee");
    const initialSupply = hre.ethers.parseUnits("1000000", 18); // 1 triệu token
    const token = await MyTokenWithDynamicFee.deploy(initialSupply);

    await token.waitForDeployment();
    console.log("MyTokenWithDynamicFee deployed to:", token.target);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
