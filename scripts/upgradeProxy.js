async function main() {
  const stratFactory = await ethers.getContractFactory('ReaperStrategyTarot');
  const stratContract = await hre.upgrades.upgradeProxy('0xa641bB87c1ed73D7C2c1a9B5cBa409CBBF6bE3A3', stratFactory, {
    timeout: 0,
  });
  console.log('Strategy upgraded!');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
