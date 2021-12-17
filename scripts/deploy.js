const { ethers } = require("ethers");

const _LIBRARIES = {
	"StringConversions": {
		"address": "0x86e4968eA75F2f95bcf3Cc75533fC294922DA07d",
		"redeploy": false,
	},
	"SeededRandomGenerator": {
		"address": "0x6ff746e3D9cBBF1D80AeD726d35348935DC2DC91",
		"redeploy": false,
	},
	"HSLGenerator": {
		"address": "0x7e1D9928faFb907009cd6Db31bae488c0123b63C",
		"redeploy": false,
	},
	"SVGGenerator": {
		"address": "0x7Dc10d1C214Fbd36F454ec5e39833BcA142614D8",
		"redeploy": true,
	},
}

async function deployContract() {
  // Deploy libraries
  for (key in _LIBRARIES) {
    if (_LIBRARIES[key]["redeploy"]) {
      console.log("Deploying library: ", key);

      var libraryContractFactory;
      if (key == "SVGGenerator") {
        libraryContractFactory = await ethers.getContractFactory(
          key,
          {
            libraries: {
              "StringConversions": _LIBRARIES["StringConversions"]["address"],
              "SeededRandomGenerator": _LIBRARIES["SeededRandomGenerator"]["address"],
              "HSLGenerator": _LIBRARIES["HSLGenerator"]["address"],
            }
          }
        );
      } else {
        libraryContractFactory = await ethers.getContractFactory(key);
      }

      var library = await libraryContractFactory.deploy();
      _LIBRARIES[key]["address"] = library.address;

      console.log("Library deployed at: ", library.address, "\n");
    }
  }

  // Deploy main contract
  console.log("Deploying main contract");

  const contractFactory = await ethers.getContractFactory(
    "Artify",
    {
      libraries: {
        "StringConversions": _LIBRARIES["StringConversions"]["address"],
        "HSLGenerator": _LIBRARIES["HSLGenerator"]["address"],
        "SVGGenerator": _LIBRARIES["SVGGenerator"]["address"],
      },
    }
  );
  const contract = await contractFactory.deploy();

  console.log("Contract deployed at: ", contract.address);
}

deployContract()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
