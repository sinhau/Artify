async function main() {
    const AnonHumansNFTContractFactory = await ethers.getContractFactory("AnonHumansNFT")
  
    // Start deployment, returning a promise that resolves to a contract object
    const AnonHumansNFT = await AnonHumansNFTContractFactory.deploy()
    console.log("Contract deployed to address:", AnonHumansNFT.address)
}
  
main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error)
    process.exit(1)
})