// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title On-chain generated SVG art based on seed phrase 
 * @author Utkarsh Sinha <sinha.karsh@gmail.com>
 */

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "./libraries/SeededRandomGenerator.sol";
import "./libraries/HSLGenerator.sol";
import "./libraries/SVGGenerator.sol";
import "./structs/HSL.sol";

contract AvatarForENS is ERC721 {
    mapping (uint256 => string) private _tokenIDToSeed;
    mapping (uint256 => string) private _tokenArt;
    uint256 private _tokenID;

    constructor() public ERC721("AvatarForENS", "ENSAVATAR") {}

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

        // Generate token art
        _tokenArt[_tokenID] = generateArt(ensName);

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
        string memory _tokenURI = generateTokenURI(seed, tokenID);
        return _tokenURI;       
    }

    /**
     * @dev Get SVG art based on token's seed.
     * 
     * @param tokenID The token ID.
     *
     * Returns SVG art as XML formatted string.
     */
    function getArt(uint256 tokenID) external view returns (string memory)
    {
        return _tokenArt[tokenID];
    }

    /**
     * @dev Generates metadata for NFT based on token's seed
     * @param seed The seed of the NFT
     */
    function generateTokenURI(string memory seed, uint tokenID) internal view returns (string memory) {
        string memory image = Base64.encode(bytes(_tokenArt[tokenID]));

        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"Avatar for ', seed, '",',
                            '"description":"Each avatar is a one of a kind on-chain generated SVG which is seeded by the ENS domain name or the wallet address of the minter.  This avatar was originally minted using the seed ', seed, '",',
                            '"image":"data:image/svg+xml;base64,', image, '"}'
                        )
                    )
                )
            )
        );
    }

    /**
     * @dev Generate custom SVG art based on token's seed.
     * @param seed The seed to generate the SVG art from
     * Returns the SVG image as bytes
     */
    function generateArt(string memory seed) internal pure returns (string memory) {
        bytes32 hashOfSeed = SeededRandomGenerator.init(seed);

        // Generate SVG element for the main polygon
        string memory parentPolygon;
        string memory parentPolygonID = "parentPolygon";
        int numOfEdges;
        (numOfEdges, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 4, 6);
        (parentPolygon, hashOfSeed) = SVGGenerator.generatePolygon(hashOfSeed, uint(numOfEdges), parentPolygonID, -200, 200);

        // Generate number of polygon groups to create
        int numOfPolygonGroups;
        (numOfPolygonGroups, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 3, 5);

        // Get enough HSL colors for each polygon group
        int colorScheme;
        (colorScheme, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 1, 2);
        int rootHue;
        (rootHue, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 0, 359);
        int rootSaturation;
        (rootSaturation, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 80, 100);
        int rootLightness;
        (rootLightness, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 30, 50);

        HSL[] memory HSLColors = new HSL[](uint(numOfPolygonGroups));

        HSL[3] memory HSLColors1 = HSLGenerator.generateHSLPalette(colorScheme, rootHue, rootSaturation, rootLightness);
        HSLColors[0] = HSLColors1[0];
        HSLColors[1] = HSLColors1[1];
        HSLColors[2] = HSLColors1[2];

        if (numOfPolygonGroups > 3) {
            HSL[3] memory HSLColors2 = HSLGenerator.generateHSLPalette(colorScheme, int(HSLColors1[1].hue), rootSaturation, rootLightness);
            for (uint i = 3; i < uint(numOfPolygonGroups); i++) {
                HSLColors[i] = HSLColors2[i - 3];
            }
        }

        // Generate polygon groups
        string memory polygonGroups = "<g id='polygonGroups'>";
        string memory polygon;
        for (uint i = 1; i <= uint(numOfPolygonGroups); i++) {
            (polygon, hashOfSeed) = SVGGenerator.generatePolygonGroup(hashOfSeed, parentPolygonID, HSLColors[i-1], i);
            polygonGroups = string(abi.encodePacked(
                polygonGroups,
                polygon
            ));
        }
        polygonGroups = string(abi.encodePacked(polygonGroups, "</g>"));


        // Assemble SVG
        return string(abi.encodePacked(
            "<svg version='1.1' width='640' height='640' viewbox='0 0 640 640' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' style='background-color:hsl(0, 100%, 0%)'>",
                "<defs>",
                    parentPolygon,
                    polygonGroups,
                "</defs>",
                "<rect width='100%' height='100%' fill='hsl(0, 100%, 0%)'/>",
                "<g>",
                    "<use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(0,0,0)'/>",
                    "<use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(60,0,0)' />",
                    "<use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(120,0,0)' />",
                    "<use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(180,0,0)' />",
                    "<use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(240,0,0)' />",
                    "<use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(300,0,0)' />",
                    "<animateTransform attributeName='transform' attributeType='XML' type='rotate' values='0 320 320;360 320 320' dur='30s' repeatCount='indefinite'/>",
                "</g>",
            "</svg>"));
    }
}