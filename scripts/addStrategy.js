async function main() {
  const vaultAddress = '0xb8138c95c686f115f8990ddA7356C3D01EFdd188';
  const Vault = await ethers.getContractFactory('ReaperVaultV2');
  const vault = Vault.attach(vaultAddress);

  const strategyAddress = '0x9081E3e1cAC7BcEf696861f6B03d2f24e5B6CF3d';
  const strategyAllocation = 9000;
  await vault.addStrategy(strategyAddress, strategyAllocation);
  console.log('Strategy added!');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
