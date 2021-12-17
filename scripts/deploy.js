async function main() {
  // Deploy BokkyPooBahsDateTimeLibrary (ONLY FOR RINKEBY deployed at 0xD8E02bB2CD8637aAFB95578f91F1a981d7b0Da48, USE PRE_DEPLOYED LIBRARY FOR MAINNET)
  // const DateTimeLibraryContractFactory = await ethers.getContractFactory(
  //   "BokkyPooBahsDateTimeLibrary"
  // );
  // const DateTimeLibrary = await DateTimeLibraryContractFactory.deploy();
  // console.log("DateTimeLibrary deployed to", DateTimeLibrary.address);

  // Deploy SeededRandomGenerator (already deployed at 0x6ff746e3D9cBBF1D80AeD726d35348935DC2DC91)
  // const SeededRandomGeneratorContractFactory = await ethers.getContractFactory(
  //   "SeededRandomGenerator"
  // );
  // const SeededRandomGeneratorContract =
  //   await SeededRandomGeneratorContractFactory.deploy();
  // console.log(
  //   "SeededRandomGenerator deployed to",
  //   SeededRandomGeneratorContract.address
  // );

  // Deploy HSLGenerator (Already deployed at 0x7e1D9928faFb907009cd6Db31bae488c0123b63C)
  // const HSLGeneratorContractFactory = await ethers.getContractFactory(
  //   "HSLGenerator"
  // );
  // const HSLGeneratorContract = await HSLGeneratorContractFactory.deploy();
  // console.log("HSLGenerator deployed to", HSLGeneratorContract.address);

  // Deploy SVGGenerator (already deployed at 0xCFf96F71d1DA411B7D56f4EB2173e0bC30bC6812)
  const SVGGeneratorContractFactory = await ethers.getContractFactory(
    "SVGGenerator",
    {
      libraries: {
        // SeededRandomGenerator: SeededRandomGeneratorContract.address,
        // HSLGenerator: HSLGeneratorContract.address,
        SeededRandomGenerator: "0x6ff746e3D9cBBF1D80AeD726d35348935DC2DC91",
        HSLGenerator: "0x7e1D9928faFb907009cd6Db31bae488c0123b63C",
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
        // HSLGenerator: HSLGeneratorContract.address,
        SVGGenerator: SVGGeneratorContract.address,
        HSLGenerator: "0x7e1D9928faFb907009cd6Db31bae488c0123b63C",
        // SVGGenerator: "0xCFf96F71d1DA411B7D56f4EB2173e0bC30bC6812",
        // BokkyPooBahsDateTimeLibrary: DateTimeLibrary.address,
        BokkyPooBahsDateTimeLibrary:
          "0xD8E02bB2CD8637aAFB95578f91F1a981d7b0Da48",
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
