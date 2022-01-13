const { expect } = require("chai");
require("dotenv").config();

const _LIBRARIES = {
  StringConversions: {
    address: process.env.STRINGS_CONVERSION_LIBRARY_ADDRESS,
    deploy: true,
  },
  SeededRandomGenerator: {
    address: process.env.SEEDED_RANDOM_GENERATOR_LIBRARY_ADDRESS,
    deploy: true,
  },
  HSLGenerator: {
    address: process.env.HSL_GENERATOR_LIBRARY_ADDRESS,
    deploy: true,
  },
  SVGGenerator: {
    address: process.env.SVG_GENERATOR_LIBRARY_ADDRESS,
    deploy: true,
  },
};

describe("Artify", function () {
  before(async function () {
    [this.owner] = await ethers.getSigners();

    // Deploy libraries
    for (key in _LIBRARIES) {
      if (_LIBRARIES[key]["deploy"]) {
        console.log("---\nDeploying library: ", key);

        var libraryContractFactory;
        if (key == "SVGGenerator") {
          libraryContractFactory = await ethers.getContractFactory(key, {
            libraries: {
              StringConversions: _LIBRARIES["StringConversions"]["address"],
              SeededRandomGenerator:
                _LIBRARIES["SeededRandomGenerator"]["address"],
              HSLGenerator: _LIBRARIES["HSLGenerator"]["address"],
            },
          });
        } else {
          libraryContractFactory = await ethers.getContractFactory(key);
        }

        var library = await libraryContractFactory.deploy();
        _LIBRARIES[key]["address"] = library.address;

        console.log("Library deployed at: ", library.address, "\n");
      }
    }
  });

  beforeEach(async function () {
    // Deploy main contract
    // console.log("---\nDeploying main contract");

    const contractFactory = await ethers.getContractFactory("Artify", {
      libraries: {
        HSLGenerator: _LIBRARIES["HSLGenerator"]["address"],
        SVGGenerator: _LIBRARIES["SVGGenerator"]["address"],
      },
    });
    this.artifyContract = await contractFactory.deploy();

    console.log("       Artify contract deployed at: ", this.artifyContract.address, "\n");
  });

  describe("Deployment", function () {
    it("Contract owner should be the hardhat owner address", async function () {
      expect(await this.artifyContract.owner()).to.equal(this.owner.address);
    });
  });
});
