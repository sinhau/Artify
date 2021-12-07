//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
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

    /**
     * @dev Generate custom SVG art based on token's seed.
     * @param seed The seed to generate the SVG art from
     * Returns the SVG image as bytes
     */
    function generateArt(string memory seed) internal pure returns (bytes memory) {
        uint _seed = uint(keccak256(abi.encode(seed)));
        uint _seedModFactor = 100000;

        // Get number of initial polygons to create (between 3-8)
        _seedModFactor += 1;
        uint _numberOfInitialPolygons = (_seed % _seedModFactor % 5) + 3;

        // Generate SVG elements for the initial polygons
        string memory _initialPolygons;
        for (uint i = 0; i < _numberOfInitialPolygons; i++) {
            string memory _polygon;
            (_polygon, _seedModFactor) = generatePolyline(_seed, _seedModFactor, i);
            _initialPolygons = string(abi.encodePacked(
                _initialPolygons,
                _polygon
            ));
        }

        // Assemble SVG
        return bytes(abi.encodePacked(
            '<svg width="270" height="270" xmlns="http://www.w3.org/2000/svg" style="background-color:#121212">',
                '<defs>',
                    '<linearGradient id="background_gradient" x1="0" y1="0" x2="100%" y2="100%" gradientUnits="userSpaceOnUse">',
                        '<stop offset="0" stop-color="#fcd744"/>',
                        '<stop offset="1" stop-color="#a1270e"/>',
                    '</linearGradient>',
                    _initialPolygons,
                    '<g id="all_polys">',
                        '<g id="poly0_group">',
                            '<use xlink:href="#poly0" transform="matrix(.38 -.42 .83 .38 -.1 .3)" />',
                            '<use xlink:href="#poly0" transform="matrix(0.2 1 0.3 -0.43 .25 .32) translate(30,21)"/>',
                            '<use xlink:href="#poly0" transform="matrix(0.3 -1.2 0.12 0.23 .43 .13) translate(43,10)"/>',
                            '<animate attributeName="opacity" values="1;0.2;1" dur="3s" repeatCount="indefinite"/>',
                            '<animateTransform attributeName="transform" attributeType="XML" type="skewX" values="0;5;0" dur="3s" repeatCount="indefinite" additive="sum"/>',
                            '<animateTransform attributeName="transform" attributeType="XML" type="skewY" values="0;5;0" dur="3s" repeatCount="indefinite" additive="sum"/>'
                        '</g>',
                        '<g id="poly1_group">',
                            '<use xlink:href="#poly1" transform="matrix(.38 -.42 .83 .38 -.1 .3)" />',
                            '<use xlink:href="#poly1" transform="matrix(0.23 .1 0.3 0.43 .35 .52) translate(30,21)"/>',
                            '<use xlink:href="#poly1" transform="matrix(0.3 -.2 0.12 0.23 .43 .13) translate(43,10)"/>',
                            '<animate attributeName="opacity" values="1;0.5;1" dur="5s" repeatCount="indefinite"/>',
                            '<animateTransform attributeName="transform" attributeType="XML" type="skewX" values="0;3;0" dur="5s" repeatCount="indefinite" additive="sum"/>',
                            '<animateTransform attributeName="transform" attributeType="XML" type="skewY" values="0;3;0" dur="5s" repeatCount="indefinite" additive="sum"/>',
                        '</g>',
                        '<g id="poly2_group">',
                            '<use xlink:href="#poly2" transform="matrix(.38 -.42 .83 .38 -.1 .3)" />',
                            '<use xlink:href="#poly2" transform="matrix(0.2 1 0.3 -0.43 .25 .32) translate(30,21)"/>',
                            '<use xlink:href="#poly2" transform="matrix(0.3 -1.2 0.12 0.23 .43 .13) translate(43,10)"/>',
                            '<animate attributeName="opacity" values="1;0.5;1" dur="7s" repeatCount="indefinite"/>',
                            '<animateTransform attributeName="transform" attributeType="XML" type="skewX" values="0;24;0" dur="7s" repeatCount="indefinite" additive="sum"/>',
                            '<animateTransform attributeName="transform" attributeType="XML" type="skewY" values="0;24;0" dur="7s" repeatCount="indefinite" additive="sum"/>',
                        '</g>',
                '</defs>',
                '<rect width="100%" height="100%" />',
                '<g>',
                    '<use xlink:href="#all_polys" transform="translate(135, 135) rotate(0,0,0)" opacity="50%" fill-opacity="50%"/>',
                    '<use xlink:href="#all_polys" transform="translate(135, 135) rotate(60,0,0)" opacity="50%" fill-opacity="50%"/>',
                    '<use xlink:href="#all_polys" transform="translate(135, 135) rotate(120,0,0)" opacity="50%" fill-opacity="50%"/>',
                    '<use xlink:href="#all_polys" transform="translate(135, 135) rotate(180,0,0)" opacity="50%" fill-opacity="50%"/>',
                    '<use xlink:href="#all_polys" transform="translate(135, 135) rotate(240,0,0)" opacity="50%" fill-opacity="50%"/>',
                    '<use xlink:href="#all_polys" transform="translate(135, 135) rotate(300,0,0)" opacity="50%" fill-opacity="50%"/>',
                    '<animateTransform attributeName="transform" attributeType="XML" type="rotate" values="0 135 135;360 135 135" dur="30s" repeatCount="indefinite"/>',
                '</g>',
            '</svg>'));
    }

    /**
     * @dev Generate polyline element based on seed
     *
     * @param seed The seed to generate the polyline from
     * @param seedModFactor The factor to mod the seed by
     * @param polyID The ID of the polyline
     *
     * Returns the SVG polyline element
     */
    function generatePolyline(uint seed, uint seedModFactor, uint polyID) internal pure returns (string memory, uint) {
        // Get number of sides for the polygon (between 3-6)
        seedModFactor += 1;
        uint _numberOfSides = (seed % seedModFactor % 3) + 3;

        string memory _polyline = string(abi.encodePacked(
            '<polyline id="poly', Strings.toString(polyID), '" points="0,0 '
        ));

        // Generate points for the polygon
        for (uint i = 0; i < _numberOfSides-1; i++) {
            string memory _point;
            (_point, seedModFactor) = getPolygonPoint(seed, seedModFactor);
            _polyline = string(abi.encodePacked(
                _polyline,
                _point,
                " "
            ));
        }

        // Close the polygon
        string memory _rgb;
        (_rgb, seedModFactor) = getRGB(seed, seedModFactor);
        _polyline = string(abi.encodePacked(
            _polyline,
            ' 0,0" fill="',
            _rgb,
            '" fill-opacity="80%"/>' 
        ));

        return (_polyline, seedModFactor);
    }

    /**
     * @dev Get polygon point position based on seed
     *
     * @param seed The seed to generate the point from
     * @param seedModFactor The factor to mod the seed by
     *
     * Returns the polygon point position as a string
     */
    function getPolygonPoint(uint seed, uint seedModFactor) internal pure returns (string memory, uint) {
        // Get the polygon point (between -50 and 50)
        seedModFactor += 1;
        uint _polygonPointX = seed % seedModFactor % 100;

        seedModFactor += 1;
        uint _polygonPointY = seed % seedModFactor % 100;


        // Get the polygon point position as string
        string memory _polygonPoint = string(abi.encodePacked(
            _polygonPointX <= 50 ? '-' : '',
            Strings.toString(_polygonPointX/2),
            ',',
            _polygonPointY <= 50 ? '-' : '',
            Strings.toString(_polygonPointY/2)
        ));

        return (_polygonPoint, seedModFactor);
    }

    /**
     * @dev Generate RGB color bassed on seed.
     *
     * @param seed The seed to generate the SVG art from
     * @param seedModFactor The factor to mod the seed by
     *
     * Returns the RGB color as a string
     */
    function getRGB(uint seed, uint seedModFactor) internal pure returns (string memory, uint) {
        // Get the polygon color (between 0 and 255)
        seedModFactor += 1;
        uint _polygonColorR = seed % seedModFactor % 256;

        seedModFactor += 1;
        uint _polygonColorG = seed % seedModFactor % 256;

        seedModFactor += 1;
        uint _polygonColorB = seed % seedModFactor % 256;

        // Get the polygon color as string
        string memory _polygonColor = string(abi.encodePacked(
            'rgb(',
            Strings.toString(_polygonColorR),
            ',',
            Strings.toString(_polygonColorG),
            ',',
            Strings.toString(_polygonColorB),
            ')'
        ));

        return (_polygonColor, seedModFactor);
    }
}