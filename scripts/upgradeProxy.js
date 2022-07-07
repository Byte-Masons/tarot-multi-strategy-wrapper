async function main() {
  const stratFactory = await ethers.getContractFactory('ReaperStrategyTarot');
  const stratContract = await hre.upgrades.upgradeProxy('0xec249B7F643539D1A4B752D8f98C07E194Bcc058', stratFactory, {
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
