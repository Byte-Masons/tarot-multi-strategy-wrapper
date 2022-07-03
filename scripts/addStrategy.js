async function main() {
  const vaultAddress = '0xcdA5deA176F2dF95082f4daDb96255Bdb2bc7C7D';
  const Vault = await ethers.getContractFactory('ReaperVaultV2');
  const vault = Vault.attach(vaultAddress);

  const strategyAddress = '0xec249B7F643539D1A4B752D8f98C07E194Bcc058';
  const strategyAllocation = 500;
  await vault.addStrategy(strategyAddress, strategyAllocation);
  console.log('Strategy added!');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
