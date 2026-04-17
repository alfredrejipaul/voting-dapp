const hre = require("hardhat");

async function main() {
  const candidates = [
    hre.ethers.encodeBytes32String("Alice"),
    hre.ethers.encodeBytes32String("Bob"),
    hre.ethers.encodeBytes32String("Carol"),
  ];

  const durationMinutes = 60;

  console.log("Deploying Voting contract...");

  const Voting = await hre.ethers.getContractFactory("Voting");
  const voting = await Voting.deploy(candidates, durationMinutes);

  await voting.waitForDeployment();

  const address = await voting.getAddress();
  console.log(`Contract deployed to: ${address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
