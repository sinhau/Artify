require("dotenv").config();

const RINKEBY_API_URL = process.env.RINKEBY_API_URL;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;
const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const { stripZeros } = require("ethers/lib/utils");
const web3 = createAlchemyWeb3(RINKEBY_API_URL);

const contract = require("../artifacts/contracts/SecretMessages.sol/SecretMessages.json");

const nftContract = new web3.eth.Contract(contract.abi, CONTRACT_ADDRESS);

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;

async function mintNFT(seed) {
  const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, "latest"); //get latest nonce

  //the transaction
  const tx = {
    from: PUBLIC_KEY,
    to: CONTRACT_ADDRESS,
    value: 10000000000000000,
    nonce: nonce,
    gas: 15000000,
    data: nftContract.methods.mintNFT(PUBLIC_KEY, seed).encodeABI(),
  };

  console.log("Minting NFT for: ", seed);
  const signPromise = web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);
  signPromise
    .then((signedTx) => {
      web3.eth
        .sendSignedTransaction(signedTx.rawTransaction, function (err, hash) {
          if (!err) {
            console.log(
              "The hash of your transaction is: ",
              hash,
              "\nCheck Alchemy's Mempool to view the status of your transaction!"
            );
          } else {
            console.log(
              "Something went wrong when submitting your transaction:",
              err
            );
          }
        })
        .then(() => {
          console.log("Minted NFT for", seed);
        });
    })
    .catch((err) => {
      console.log(" Promise failed:", err);
    });
}

var seed = process.argv[2];
mintNFT(seed);
