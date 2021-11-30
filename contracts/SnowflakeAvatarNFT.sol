//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import 'base64-sol/base64.sol';


contract SnowflakeAvatarNFT is ERC721 {
    mapping (uint256 => string) private _tokenIDToSeed;
    uint256 private _tokenID;

    constructor() public ERC721("SnowflakeAvatarNFT", "SNOWFLAKE") {}

    /**
     * @dev Mints a new NFT token.
     *
     * Returns the token ID of the newly minted NFT.
     */
    function mintNFT(address minter, string calldata ensName) external returns (uint256)
    {
        // Mint the token
        _tokenID += 1;
        _safeMint(minter, _tokenID);
        
        // Set the token's seed
        _tokenIDToSeed[_tokenID] = ensName;

        return _tokenID;
    }

    /**
     * @dev Generate custom SVG art based on token's seed.
     *
     * Returns the URI with "data:image/svg+xml;base64," prefix containing the SVG art.
     */
    function tokenURI(uint256 tokenID) public view override returns (string memory)
    {
        string memory seed = _tokenIDToSeed[tokenID];
        string memory _tokenURI = generateTokenURI(seed);
        return _tokenURI;       
    }

    /**
     * @dev Generate custom SVG art based on token's seed.
     * @param seed The seed to generate the SVG art from
     * Returns the SVG image as bytes
     */
    function generateArt(string memory seed) internal pure returns (bytes memory) {
        return bytes(abi.encodePacked(
            '<svg width="350" height="350" xmlns="http://www.w3.org/2000/svg" style="background-color:#121212"><rect width="100%" height="100%" fill="url(#prefix__a)"/><defs><linearGradient id="prefix__a" x1="0" y1="0" x2="100%" y2="100%" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#fcd744"/><stop offset=".091" stop-color="#fad242"/><stop offset=".182" stop-color="#f4c53e"/><stop offset=".273" stop-color="#ebb338"/><stop offset=".364" stop-color="#e19c30"/><stop offset=".455" stop-color="#d58329"/><stop offset=".545" stop-color="#c86b21"/><stop offset=".636" stop-color="#bc551b"/><stop offset=".727" stop-color="#b24215"/><stop offset=".818" stop-color="#a93311"/><stop offset=".909" stop-color="#a32a0f"/><stop offset="1" stop-color="#a1270e"/></linearGradient></defs><text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" style="font:700 20px sans-serif" fill="#fff">',
            seed,
            '</text></svg>'));
    }

    /**
     * @dev Generates metadata for NFT based on token's seed
     * @param seed The seed of the NFT
     */
    function generateTokenURI(string memory seed) internal pure returns (string memory) {
        string memory image = Base64.encode(generateArt(seed));

        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"Snowflake for ', seed, '",',
                            '"description":"Each snowflake is a one of a kind on-chain generated SVG which is seeded by the ENS domain name of the minter.  This avatar was originally minted by "', seed,
                            '"image":"data:image/svg+xml;base64,', image, '"}'
                        )
                    )
                )
            )
        );
    }
}