async function main() {
  // Deploy SeededRandomGenerator
  const SeededRandomGeneratorContractFactory = await ethers.getContractFactory(
    "SeededRandomGenerator"
  );
  const SeededRandomGeneratorContract =
    await SeededRandomGeneratorContractFactory.deploy();
  console.log(
    "SeededRandomGenerator deployed to",
    SeededRandomGeneratorContract.address
  );

  // Deploy HSLGenerator
  const HSLGeneratorContractFactory = await ethers.getContractFactory(
    "HSLGenerator"
  );
  const HSLGeneratorContract = await HSLGeneratorContractFactory.deploy();
  console.log("HSLGenerator deployed to", HSLGeneratorContract.address);

  // Deploy SVGGenerator
  const SVGGeneratorContractFactory = await ethers.getContractFactory(
    "SVGGenerator",
    {
      libraries: {
        SeededRandomGenerator: SeededRandomGeneratorContract.address,
        HSLGenerator: HSLGeneratorContract.address,
      },
    }
  );
  const SVGGeneratorContract = await SVGGeneratorContractFactory.deploy();
  console.log("SVGGenerator deployed to", SVGGeneratorContract.address);

  // Deploy main contract
  const AvatarForENSContractFactory = await ethers.getContractFactory(
    "AvatarForENS",
    {
      libraries: {
        HSLGenerator: HSLGeneratorContract.address,
        SVGGenerator: SVGGeneratorContract.address,
      },
    }
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
