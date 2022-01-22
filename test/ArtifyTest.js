const { expect } = require("chai");
const { ethers } = require("hardhat");
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
    this.accounts = await ethers.getSigners();
    this.owner = this.accounts[0];

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

    // console.log(
    //   "       Artify contract deployed at: ",
    //   this.artifyContract.address,
    //   "\n"
    // );
  });

  describe("Deployment", function () {
    it("Contract owner should be the hardhat owner address", async function () {
      expect(await this.artifyContract.owner()).to.equal(this.owner.address);
    });
  });

  describe("Minting", function () {
    it("Validate MINT_FEE working correctly", async function () {
      await expect(
        this.artifyContract.mintNFT(this.owner.address, "Test minting")
      ).to.be.revertedWith("Not enough ETH to mint");
      await expect(
        this.artifyContract.mintNFT(this.owner.address, "Test minting", {
          value: ethers.utils.parseEther("0.001"),
        })
      ).to.be.revertedWith("Not enough ETH to mint");

      await expect(
        this.artifyContract.mintNFT(this.owner.address, "Test minting", {
          value: ethers.utils.parseEther("0.01"),
        })
      ).to.be.revertedWith("Cannot mint NFT before public sale starts");
    });

    it("Validate public sale modification/check working correctly", async function () {
      await expect(
        this.artifyContract.mintNFT(this.owner.address, "Test minting", {
          value: ethers.utils.parseEther("0.01"),
        })
      ).to.be.revertedWith("Cannot mint NFT before public sale starts");

      await this.artifyContract.changeSaleStartTime(1545084801);

      await this.artifyContract.mintNFT(this.owner.address, "Test minting", {
        value: ethers.utils.parseEther("0.01"),
      });

      expect(await this.artifyContract.ownerOf(1)).to.equal(this.owner.address);
    });

    it("Validate isSalePaused update/check working correctly", async function () {
      await this.artifyContract.changeSaleStartTime(1545084801);
      await this.artifyContract.mintNFT(this.owner.address, "Test minting", {
        value: ethers.utils.parseEther("0.01"),
      });
      expect(await this.artifyContract.ownerOf(1)).to.equal(this.owner.address);

      await this.artifyContract.setSalePauseStatus(true);
      await expect(
        this.artifyContract.mintNFT(this.owner.address, "Test minting", {
          value: ethers.utils.parseEther("0.01"),
        })
      ).to.be.revertedWith("Cannot mint NFT while the sale is paused");
    });

    it("Validate whitelisting working correctly", async function () {
      await expect(
        this.artifyContract.mintNFT(this.owner.address, "Test minting")
      ).to.be.revertedWith("Not enough ETH to mint");

      await expect(
        this.artifyContract.mintNFT(this.owner.address, "Test minting", {
          value: ethers.utils.parseEther("0.01"),
        })
      ).to.be.revertedWith("Cannot mint NFT before public sale starts");

      await this.artifyContract.updateWhitelistStatus(this.owner.address, true);

      await this.artifyContract.mintNFT(this.owner.address, "Test minting");

      expect(await this.artifyContract.ownerOf(1)).to.equal(this.owner.address);
    });

    it("Validate empty message check working correctly", async function () {
      await this.artifyContract.updateWhitelistStatus(this.owner.address, true);

      await expect(
        this.artifyContract.mintNFT(this.owner.address, "")
      ).to.be.revertedWith("No message provided");

      await this.artifyContract.mintNFT(this.owner.address, "Test minting");

      expect(await this.artifyContract.ownerOf(1)).to.equal(this.owner.address);
    });

    it("Should not be able to get seed for tokenID 1", async function () {
      await expect(this.artifyContract.tokenURI(1)).to.be.revertedWith(
        "TokenID not created yet"
      );
    });

    it("Validate balance withdrawal working correctly", async function () {
      await this.artifyContract.updateWhitelistStatus(this.owner.address, true);
      await this.artifyContract.mintNFT(this.owner.address, "Test minting", {
        value: ethers.utils.parseEther("0.01"),
      });
      await this.artifyContract.mintNFT(this.owner.address, "Test minting", {
        value: ethers.utils.parseEther("0.01"),
      });
      var contractBalance = await this.artifyContract.provider.getBalance(
        this.artifyContract.address
      );
      expect(contractBalance.div(1000000000).toString()).to.equal("20000000");

      await this.artifyContract.withdrawFullBalance();
      contractBalance = await this.artifyContract.provider.getBalance(
        this.artifyContract.address
      );
      expect(contractBalance.div(1000000000).toString()).to.equal("0");
    });

    it("Validate minting from multiple addresses", async function () {
      await this.artifyContract.updateWhitelistStatus(this.owner.address, true);
      await this.artifyContract.mintNFT(this.owner.address, "Test minting", {
        value: ethers.utils.parseEther("0.01"),
      });
      expect(await this.artifyContract.ownerOf(1)).to.equal(this.owner.address);

      await this.artifyContract.updateWhitelistStatus(this.accounts[1].address, true);
      await this.artifyContract.mintNFT(this.accounts[1].address, "Test minting 2", {
        value: ethers.utils.parseEther("0.01"),
      });
      expect(await this.artifyContract.ownerOf(2)).to.equal(this.accounts[1].address);
    });
  });
});
