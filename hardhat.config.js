/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 require('dotenv').config();
 require("@nomiclabs/hardhat-waffle");
 const { RINKEBY_API_URL, PRIVATE_KEY } = process.env;
 module.exports = {
    solidity: "0.8.9",
    networks: {
       hardhat: {},
       rinkeby: {
          url: RINKEBY_API_URL,
          accounts: [`0x${PRIVATE_KEY}`]
       }
    },
 }
 