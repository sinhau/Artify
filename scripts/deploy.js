async function main() {
  // Deploy BokkyPooBahsDateTimeLibrary (ONLY FOR RINKEBY deployed at 0xD8E02bB2CD8637aAFB95578f91F1a981d7b0Da48, USE PRE_DEPLOYED LIBRARY FOR MAINNET)
  // const DateTimeLibraryContractFactory = await ethers.getContractFactory(
  //   "BokkyPooBahsDateTimeLibrary"
  // );
  // const DateTimeLibrary = await DateTimeLibraryContractFactory.deploy();
  // console.log("DateTimeLibrary deployed to", DateTimeLibrary.address);

  // Deploy StringConversions (already deployed at 0x86e4968eA75F2f95bcf3Cc75533fC294922DA07d)
  // const StringConversionsContractFactory = await ethers.getContractFactory("StringConversions");
  // const StringConversionsContract = await StringConversionsContractFactory.deploy();
  // console.log("StringConversions deployed to", StringConversionsContract.address);

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

  // Deploy SVGGenerator (already deployed at 0x7Dc10d1C214Fbd36F454ec5e39833BcA142614D8)
  const SVGGeneratorContractFactory = await ethers.getContractFactory(
    "SVGGenerator",
    {
      libraries: {
        // SeededRandomGenerator: SeededRandomGeneratorContract.address,
        // HSLGenerator: HSLGeneratorContract.address,
        SeededRandomGenerator: "0x6ff746e3D9cBBF1D80AeD726d35348935DC2DC91",
        HSLGenerator: "0x7e1D9928faFb907009cd6Db31bae488c0123b63C",
        // StringConversions: StringConversionsContract.address,
        StringConversions: "0x86e4968eA75F2f95bcf3Cc75533fC294922DA07d",
      },
    }
  );
  const SVGGeneratorContract = await SVGGeneratorContractFactory.deploy();
  console.log("SVGGenerator deployed to", SVGGeneratorContract.address);

  // Deploy main contract
  const ArtsyMessagesContractFactory = await ethers.getContractFactory(
    "ArtsyMessages",
    {
      libraries: {
        // HSLGenerator: HSLGeneratorContract.address,
        SVGGenerator: SVGGeneratorContract.address,
        HSLGenerator: "0x7e1D9928faFb907009cd6Db31bae488c0123b63C",
        // SVGGenerator: "0x7Dc10d1C214Fbd36F454ec5e39833BcA142614D8",
        // BokkyPooBahsDateTimeLibrary: DateTimeLibrary.address,
        // BokkyPooBahsDateTimeLibrary:
        //   "0xD8E02bB2CD8637aAFB95578f91F1a981d7b0Da48",
        // StringConversions: StringConversionsContract.address,
        StringConversions: "0x86e4968eA75F2f95bcf3Cc75533fC294922DA07d",
      },
    }
  );
  const ArtsyMessagesContract = await ArtsyMessagesContractFactory.deploy();
  console.log("ArtsyMessages deployed to address:", ArtsyMessagesContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
