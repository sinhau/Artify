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

  // Deploy SVGGenerator (already deployed at 0x10D3264c2B257EB33Ee53C0A30f408ab6083C5cD)
  // const SVGGeneratorContractFactory = await ethers.getContractFactory(
  //   "SVGGenerator",
  //   {
  //     libraries: {
  //       SeededRandomGenerator: "0x241340e863ae394dDE6cd873960512FBA284fc7E",
  //       HSLGenerator: "0x150f9BA13F65C391207A832fA3d487B6D5f262e6"
  //     },
  //   }
  // );
  // const SVGGeneratorContract = await SVGGeneratorContractFactory.deploy();
  // console.log("SVGGenerator deployed to", SVGGeneratorContract.address);

  // Deploy main contract
  const AvatarForENSContractFactory = await ethers.getContractFactory(
    "AvatarForENS",
    {
      libraries: {
        HSLGenerator: "0x150f9BA13F65C391207A832fA3d487B6D5f262e6",
        SVGGenerator: "0x10D3264c2B257EB33Ee53C0A30f408ab6083C5cD",
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
