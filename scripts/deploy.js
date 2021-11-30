async function main() {
    const SnowflakeAvatarNFTContractFactory = await ethers.getContractFactory("SnowflakeAvatarNFT")
  
    // Start deployment, returning a promise that resolves to a contract object
    const SnowflakeAvatarNFT = await SnowflakeAvatarNFTContractFactory.deploy()
    console.log("Contract deployed to address:", SnowflakeAvatarNFT.address)
}
  
main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error)
    process.exit(1)
})