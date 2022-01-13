require("dotenv").config();

const RINKEBY_API_URL = process.env.RINKEBY_API_URL;
const CONTRACT_ADDRESS = process.env.ARTIFY_CONTRACT_ADDRESS;
const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(RINKEBY_API_URL);

const contract = require("../artifacts/contracts/Artify.sol/Artify.json");

const nftContract = new web3.eth.Contract(contract.abi, CONTRACT_ADDRESS);

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PUBLIC_KEY = process.env.PUBLIC_KEY;

async function getSaleStartTime() {
  const resp = await nftContract.methods.publicSaleStartTime().call();
  var saleTime = new Date(0); // The 0 there is the key, which sets the date to the epoch
  saleTime.setUTCSeconds(resp);
  console.log(saleTime.toLocaleString("en-US", {timeZone: "America/Los_Angeles"}));
}

getSaleStartTime();
