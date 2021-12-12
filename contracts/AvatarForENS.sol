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
import "./libraries/HSLGenerator.sol";
import "./libraries/SVGGenerator.sol";
import "./structs/HSL.sol";
import "./structs/ArtAttributes.sol";

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

        // Get art attributes
        ArtAttributes memory artAttributes;
        (artAttributes, ) = SVGGenerator.generateArtAttributes(seed);

        string memory colorScheme;
        if (artAttributes.colorScheme == 1) {
            colorScheme = "triadic";
        } else if (artAttributes.colorScheme == 2) {
            colorScheme = "split_complimentary";
        } else if (artAttributes.colorScheme == 3) {
            colorScheme = "analogous";
        }

        HSL memory hsl = HSL(uint(artAttributes.rootHue), uint(artAttributes.rootSaturation), uint(artAttributes.rootLightness));

        // Assemble attributes string
        string memory attributes = "";
        attributes = string(abi.encodePacked(
            "[",
                "{",
                    '"trait_type":"Polygon Edge Count",',
                    '"value":"', Strings.toString(uint(artAttributes.numOfEdges)),'"',
                "},",
                "{",
                    '"trait_type":"Polygon Layer Count",',
                    '"value":"', Strings.toString(uint(artAttributes.numOfPolygonGroups)),'"',
                "},",
                "{",
                    '"trait_type":"Color Scheme",',
                    '"value":"', colorScheme,'"',
                "},",
                "{",
                    '"trait_type":"Root HSL",',
                    '"value":"', HSLGenerator.toString(hsl),'"',
                "}",
            "]"
        ));

        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"Avatar for ', seed, '",',
                            '"description":"Each avatar is a one of a kind on-chain generated SVG which is seeded by the ENS domain name or the wallet address of the minter.  This avatar was originally minted using the seed ', seed, '",',
                            '"image":"data:image/svg+xml;base64,', image, '",',
                            '"attributes":', attributes, '}'
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
        ArtAttributes memory artAttributes;
        bytes32 hashOfSeed;
        (artAttributes, hashOfSeed) = SVGGenerator.generateArtAttributes(seed);

        // Generate SVG element for the main polygon
        string memory parentPolygon;
        string memory parentPolygonID = "parentPolygon";
        (parentPolygon, hashOfSeed) = SVGGenerator.generatePolygon(hashOfSeed, uint(artAttributes.numOfEdges), parentPolygonID, -200, 200);

        // Generate HSL color pallete for all the polygon layers
        HSL[] memory HSLColors = new HSL[](uint(artAttributes.numOfPolygonGroups));

        HSL[3] memory HSLColors1 = HSLGenerator.generateHSLPalette(artAttributes.colorScheme, artAttributes.rootHue, artAttributes.rootSaturation, artAttributes.rootLightness);
        HSLColors[0] = HSLColors1[0];
        HSLColors[1] = HSLColors1[1];
        HSLColors[2] = HSLColors1[2];

        if (artAttributes.numOfPolygonGroups > 3) {
            HSL[3] memory HSLColors2 = HSLGenerator.generateHSLPalette(artAttributes.colorScheme, int(HSLColors1[1].hue), artAttributes.rootSaturation, artAttributes.rootLightness);
            for (uint i = 3; i < uint(artAttributes.numOfPolygonGroups); i++) {
                HSLColors[i] = HSLColors2[i - 2]; //NOTE: i-2 will only work when numOfPolygonGroups is 5 or less
            }
        }

        // Generate polygon groups
        string memory polygonGroups = "<g id='polygonGroups'>";
        string memory polygon;
        for (uint i = 1; i <= uint(artAttributes.numOfPolygonGroups); i++) {
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