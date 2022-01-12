const { ethers } = require("hardhat");
require("dotenv").config();

const _LIBRARIES = {
	"StringConversions": {
		"address": process.env.STRINGS_CONVERSION_LIBRARY_ADDRESS,
		"deploy": false,
	},
	"SeededRandomGenerator": {
		"address": process.env.SEEDED_RANDOM_GENERATOR_LIBRARY_ADDRESS,
		"deploy": false,
	},
	"HSLGenerator": {
		"address": process.env.HSL_GENERATOR_LIBRARY_ADDRESS,
		"deploy": false,
	},
	"SVGGenerator": {
		"address": process.env.SVG_GENERATOR_LIBRARY_ADDRESS,
		"deploy": true,
	},
}

async function deployContract() {
  // Deploy libraries
  for (key in _LIBRARIES) {
    if (_LIBRARIES[key]["deploy"]) {
      console.log("---\nDeploying library: ", key);

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
  console.log("---\nDeploying main contract");

  const contractFactory = await ethers.getContractFactory(
    "Artify",
    {
      libraries: {
        "HSLGenerator": _LIBRARIES["HSLGenerator"]["address"],
        "SVGGenerator": _LIBRARIES["SVGGenerator"]["address"],
      },
    }
  );
  const contract = await contractFactory.deploy();

  console.log("Contract deployed at: ", contract.address, "\n");
}

deployContract()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
