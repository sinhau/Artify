async function main() {
  // Deploy SeededRandomGenerator (already deployed at 0x241340e863ae394dDE6cd873960512FBA284fc7E)
  // const SeededRandomGeneratorContractFactory = await ethers.getContractFactory(
  //   "SeededRandomGenerator"
  // );
  // const SeededRandomGeneratorContract =
  //   await SeededRandomGeneratorContractFactory.deploy();
  // console.log(
  //   "SeededRandomGenerator deployed to",
  //   SeededRandomGeneratorContract.address
  // );

  // Deploy HSLGenerator (Already deployed at 0x150f9BA13F65C391207A832fA3d487B6D5f262e6)
  // const HSLGeneratorContractFactory = await ethers.getContractFactory(
  //   "HSLGenerator"
  // );
  // const HSLGeneratorContract = await HSLGeneratorContractFactory.deploy();
  // console.log("HSLGenerator deployed to", HSLGeneratorContract.address);

  // Deploy SVGGenerator (already deployed at 0x18B1581537CFf883a58c0546802A5DBD211b2ea3)
  const SVGGeneratorContractFactory = await ethers.getContractFactory(
    "SVGGenerator",
    {
      libraries: {
        SeededRandomGenerator: "0x241340e863ae394dDE6cd873960512FBA284fc7E",
        HSLGenerator: "0x150f9BA13F65C391207A832fA3d487B6D5f262e6",
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
        HSLGenerator: "0x150f9BA13F65C391207A832fA3d487B6D5f262e6",
        SVGGenerator: SVGGeneratorContract.address,
        // SVGGenerator: "0x18B1581537CFf883a58c0546802A5DBD211b2ea3",
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
