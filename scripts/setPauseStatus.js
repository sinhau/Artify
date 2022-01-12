require("dotenv").config();

const RINKEBY_API_URL = process.env.RINKEBY_API_URL;
const CONTRACT_ADDRESS = process.env.ARTIFY_CONTRACT_ADDRESS;
const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(RINKEBY_API_URL);

const contract = require("../artifacts/contracts/Artify.sol/Artify.json");

const nftContract = new web3.eth.Contract(contract.abi, CONTRACT_ADDRESS);

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;

async function setPauseStatus(pauseStatus) {
  const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, "latest"); //get latest nonce

  //the transaction
  const tx = {
    from: PUBLIC_KEY,
    to: CONTRACT_ADDRESS,
    nonce: nonce,
    gas: 150000,
    data: nftContract.methods.setSalePauseStatus(pauseStatus).encodeABI(),
  };

  const signPromise = web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);
  signPromise
    .then((signedTx) => {
      web3.eth
        .sendSignedTransaction(signedTx.rawTransaction, function (err, hash) {
          if (!err) {
            console.log("Changing pause status to: ", pauseStatus);
          } else {
            console.log(
              "Something went wrong when submitting your transaction:",
              err
            );
          }
        })
        .then(() => {
          console.log("Pause status changed successfully!");
        });
    })
    .catch((err) => {
      console.log(" Promise failed:", err);
    });
}

var inp = process.argv[2];
var pauseStatus = inp === "true" ? true : false;
setPauseStatus(pauseStatus);
