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
        uint memory _seed = uint(keccak256(abi.encode(seed)));

        // Get number of initial polygons to create
        uint memory _numberOfInitialPolygons = seededRandom(3, 10, _seed);

        // Generate SVG elements for the initial polygons
        string[] memory _initialPolygonsSVG = new string[_numberOfInitialPolygons];
        for (uint i = 0; i < _numberOfInitialPolygons; i++) {
            _initialPolygonsSVG[i] = generatePolylineElement();
        }

        return bytes(abi.encodePacked(
            '<svg width="270" height="270" xmlns="http://www.w3.org/2000/svg" style="background-color:#121212"><rect width="100%" height="100%" fill="url(#background_gradient)"/>',
                '<defs>',
                    '<linearGradient id="background_gradient" x1="0" y1="0" x2="100%" y2="100%" gradientUnits="userSpaceOnUse">',
                        '<stop offset="0" stop-color="#fcd744"/>',
                        '<stop offset="1" stop-color="#a1270e"/>',
                    '</linearGradient>',
                '</defs>',
            '</svg>'));
    }

    /**
     * @dev Generate polyline element.
     * Returns string containing SVG polyline element
     */
    function generatePolylineElement() internal pure returns (string memory) {
        // Get number of points to create in the polygon
        uint memory _numberOfPoints = seededRandom(3, 10, _seed);
        
        return ""
        // <polyline id="poly1" points="0,0 4,2 19,33 19,3, 0,0" stroke="#ff00f2" stroke-width="2" stroke-opacity="20%" fill="#945f10" fill-opacity="50%"/>
    }

    /**
     * @dev Generate random number using the provided seed between provided min and max
     * @param min The minimum number
     * @param max The maximum number
     * @param seed The seed to generate the random number from
     * Returns the random number
     */
    function seededRandom(uint256 min, uint256 max, uint256 seed) internal pure returns (uint256) {
        return (seed % (max - min)) + min;
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
                            '"description":"Each snowflake is a one of a kind on-chain generated SVG which is seeded by the ENS domain name of the minter.  This avatar was originally minted by ', seed, '",',
                            '"image":"data:image/svg+xml;base64,', image, '"}'
                        )
                    )
                )
            )
        );
    }
}