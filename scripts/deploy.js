async function main() {
  // Deploy main contract
  const AvatarForENSContractFactory = await ethers.getContractFactory(
    "AvatarForENS"
  );
  const AvatarForENS = await AvatarForENSContractFactory.deploy();
  console.log("AvatarForENS deployed to address:", AvatarForENS.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
