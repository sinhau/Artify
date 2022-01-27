const { expect } = require("chai");
const { ethers } = require("hardhat");
var DomParser = require("dom-parser");

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
        StringConversions: _LIBRARIES["StringConversions"]["address"],
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


    it("Validate contractURI is correct", async function () {
      const resp = await this.artifyContract.contractURI();
      const jsonResp = Buffer.from(resp.substring(29), "base64").toString();
      const contractURI = JSON.parse(jsonResp);
      const image = Buffer.from(
        contractURI.image.substring(25),
        "base64"
      ).toString();
      var parser = new DomParser();
      var doc = parser.parseFromString(image, "image/svg+xml");
      // Get the SVG element
      // var svg = doc.getElementsByTagName("message")[0];
      expect(doc.rawHTML.startsWith("<svg version='1.1' width='640' height='640' viewbox='0 0 640 640' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' style='background-color:hsl(0, 100%, 0%)'>")).to.be.true;
      expect(contractURI.name).to.equal("Artify");
    });
  });

  describe("Minting", function () {
    it("Validate MINT_FEE working correctly", async function () {
      await expect(this.artifyContract.mintWalletAvatar()).to.be.revertedWith(
        "Not enough ETH to mint"
      );
      await expect(
        this.artifyContract.mintWalletAvatar({
          value: ethers.utils.parseEther("0.001"),
        })
      ).to.be.revertedWith("Not enough ETH to mint");

      await expect(
        this.artifyContract.mintWalletAvatar({
          value: ethers.utils.parseEther("0.01"),
        })
      ).to.be.revertedWith("Cannot mint NFT before public sale starts");
    });

    it("Validate public sale modification/check working correctly", async function () {
      await expect(
        this.artifyContract.mintWalletAvatar({
          value: ethers.utils.parseEther("0.01"),
        })
      ).to.be.revertedWith("Cannot mint NFT before public sale starts");

      await this.artifyContract.changeSaleStartTime(1545084801);

      await this.artifyContract.mintWalletAvatar({
        value: ethers.utils.parseEther("0.01"),
      });

      expect(await this.artifyContract.ownerOf(1)).to.equal(this.owner.address);
    });

    it("Validate isSalePaused update/check working correctly", async function () {
      await this.artifyContract.updateWhitelistStatus(this.owner.address, true);
      await this.artifyContract.setSalePauseStatus(true);
      await expect(
        this.artifyContract.mintWalletAvatar({
          value: ethers.utils.parseEther("0.01"),
        })
      ).to.be.revertedWith("Cannot mint NFT while the sale is paused");

      await this.artifyContract.setSalePauseStatus(false);
      await this.artifyContract.mintWalletAvatar({
        value: ethers.utils.parseEther("0.01"),
      });
      expect(await this.artifyContract.ownerOf(1)).to.equal(this.owner.address);
    });

    it("Validate whitelisting working correctly", async function () {
      await expect(this.artifyContract.mintWalletAvatar()).to.be.revertedWith(
        "Not enough ETH to mint"
      );

      await expect(
        this.artifyContract.mintWalletAvatar({
          value: ethers.utils.parseEther("0.01"),
        })
      ).to.be.revertedWith("Cannot mint NFT before public sale starts");

      await this.artifyContract.updateWhitelistStatus(this.owner.address, true);

      await this.artifyContract.mintWalletAvatar();

      expect(await this.artifyContract.ownerOf(1)).to.equal(this.owner.address);
    });

    it("Should not be able to get seed for tokenID 1", async function () {
      await expect(this.artifyContract.tokenURI(1)).to.be.revertedWith(
        "TokenID not created yet"
      );
    });

    it("Validate minting is working correctly", async function () {
      await this.artifyContract.updateWhitelistStatus(
        this.accounts[1].address,
        true
      );
      await this.artifyContract.connect(this.accounts[1]).mintWalletAvatar({
        value: ethers.utils.parseEther("0.01"),
      });

      expect(await this.artifyContract.ownerOf(1)).to.equal(
        this.accounts[1].address
      );
      const image = await this.artifyContract.getArt(1);
      expect(image.startsWith("<svg version='1.1' width='640' height='640' viewbox='0 0 640 640' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' style='background-color:hsl(0, 100%, 0%)'>")).to.be.true;
    });

    it("Validate tokenURI is correct", async function () {
      await this.artifyContract.updateWhitelistStatus(
        this.accounts[1].address,
        true
      );
      await this.artifyContract.connect(this.accounts[1]).mintWalletAvatar({
        value: ethers.utils.parseEther("0.01"),
      });
      const resp = await this.artifyContract.tokenURI(1);
      const json = Buffer.from(resp.substring(29), "base64").toString();
      const tokenURI = JSON.parse(json);
      expect(tokenURI.name).to.equal("Artify #1");

      const image = Buffer.from(tokenURI.image.substring(25), "base64").toString();
      expect(image.startsWith("<svg version='1.1' width='640' height='640' viewbox='0 0 640 640' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' style='background-color:hsl(0, 100%, 0%)'>")).to.be.true;
    });

    it("Validate balance withdrawal working correctly", async function () {
      await this.artifyContract.updateWhitelistStatus(this.owner.address, true);
      await this.artifyContract.updateWhitelistStatus(
        this.accounts[1].address,
        true
      );

      await this.artifyContract.mintWalletAvatar({
        value: ethers.utils.parseEther("0.01"),
      });
      await this.artifyContract.connect(this.accounts[1]).mintWalletAvatar({
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

    it("Validate that only one avatar per wallet can be minted", async function () {
      await this.artifyContract.updateWhitelistStatus(this.owner.address, true);
      await this.artifyContract.mintWalletAvatar({
        value: ethers.utils.parseEther("0.01"),
      });
      expect(await this.artifyContract.ownerOf(1)).to.equal(this.owner.address);

      await expect(
        this.artifyContract.mintWalletAvatar({
          value: ethers.utils.parseEther("0.01"),
        })
      ).to.be.revertedWith("Wallet already has an avatar");
    });

    it("Validate that message minting is working", async function () {
      await this.artifyContract.updateWhitelistStatus(this.owner.address, true);
      await this.artifyContract.mintMessage("Test minting", {
        value: ethers.utils.parseEther("0.01"),
      });
      expect(await this.artifyContract.ownerOf(1)).to.equal(this.owner.address);

      const resp = await this.artifyContract.tokenURI(1);
      const json = Buffer.from(resp.substring(29), "base64").toString();
      const tokenURI = JSON.parse(json);
      expect(tokenURI.description).to.equal("Test minting");

      await this.artifyContract.updateWhitelistStatus(this.accounts[1].address, true);
      await this.artifyContract.connect(this.accounts[1]).mintMessage("Some reaaaaaaaaaalllllyyyyyyy loooooooooooooooooong messageeeeeeeeeeee", {
        value: ethers.utils.parseEther("0.01"),
      });
      expect(await this.artifyContract.ownerOf(2)).to.equal(this.accounts[1].address);

      const resp2 = await this.artifyContract.tokenURI(2);
      const json2 = Buffer.from(resp2.substring(29), "base64").toString();
      const tokenURI2 = JSON.parse(json2);
      expect(tokenURI2.description).to.equal("Some reaaaaaaaaaalllllyyyyyyy loooooooooooooooooong messageeeeeeeeeeee");
      const image2 = Buffer.from(tokenURI2.image.substring(25), "base64").toString();
      expect(image2.startsWith("<svg version='1.1' width='640' height='640' viewbox='0 0 640 640' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' style='background-color:hsl(0, 100%, 0%)'>")).to.be.true;
    });
  });
});
