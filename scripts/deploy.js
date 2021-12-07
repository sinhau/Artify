async function main() {
  const AvatarForENsContractFactory = await ethers.getContractFactory(
    "AvatarForENS"
  );

  // Start deployment, returning a promise that resolves to a contract object
  const AvatarForENS = await AvatarForENsContractFactory.deploy();
  console.log("Contract deployed to address:", AvatarForENS.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
