async function main() {
  const stratFactory = await ethers.getContractFactory('ReaperStrategyTarot');
  const stratContract = await hre.upgrades.upgradeProxy('0x58907Ac386dB688860125bdB035Ae24505fA28e4', stratFactory, {
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
