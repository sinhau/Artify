//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import 'base64-sol/base64.sol';


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
    function getArt(uint256 tokenID) public view returns (string memory)
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
        uint _seed = uint(keccak256(abi.encode(seed)));
        uint _seedModFactor = 100000;

        // Generate SVG elements for the initial polygons
        string memory _mainPolygon;
        (_mainPolygon, _seedModFactor) = generatePolyline(_seed, _seedModFactor);

        // Generate colors
        string[4] memory _colors;
        (_colors, _seedModFactor) = generateColors(_seed, _seedModFactor);

        // Assemble SVG
        // return string(abi.encodePacked(
        //     '<svg width="270" height="270" xmlns="http://www.w3.org/2000/svg" style="background-color:#121212">',
        //         '<defs>',
        //             _mainPolygon,
        //             '<g id="poly_group">',
        //                 '<use xlink:href="#poly" transform="matrix(0.77 0.81 -0.87 -0.33 0.86 0.84)" fill="', _colors[0], '">',
        //                     '<animate attributeName="opacity" values="1;0.3;1" dur="3s" repeatCount="indefinite"/>',
        //                     '<animateTransform attributeName="transform" attributeType="XML" type="skewX" values="0;25;0;-25;0" dur="3s" repeatCount="indefinite" additive="sum"/>',
        //                     '<animateTransform attributeName="transform" attributeType="XML" type="skewY" values="0;10;0;-10;0" dur="3s" repeatCount="indefinite" additive="sum"/>',
        //                 '</use>',
        //                 '<use xlink:href="#poly" transform="matrix(-0.81 0.41 0.65 0.26 0.3 -0.43) translate(40,0)" fill="', _colors[1], '">',
        //                     '<animate attributeName="opacity" values="1;0.3;1" dur="5s" repeatCount="indefinite"/>',
        //                     '<animateTransform attributeName="transform" attributeType="XML" type="skewX" values="0;20;0;-20;0" dur="5s" repeatCount="indefinite" additive="sum"/>',
        //                     '<animateTransform attributeName="transform" attributeType="XML" type="skewY" values="0;15;0;-15;0" dur="5s" repeatCount="indefinite" additive="sum"/>',
        //                 '</use>',
        //                 '<use xlink:href="#poly" transform="matrix(0.08 -0.36 -0.25 0.76 0.87 0.68) translate(0,40)" fill="', _colors[2], '">',
        //                     '<animate attributeName="opacity" values="1;0.3;1" dur="7s" repeatCount="indefinite"/>',
        //                     '<animateTransform attributeName="transform" attributeType="XML" type="skewX" values="0;15;0;-15;0" dur="7s" repeatCount="indefinite" additive="sum"/>',
        //                     '<animateTransform attributeName="transform" attributeType="XML" type="skewY" values="0;20;0;-20;0" dur="7s" repeatCount="indefinite" additive="sum"/>',
        //                 '</use>',
        //                 '<use xlink:href="#poly" transform="matrix(1.3 .2 .12 -0.23 -2.43 .13) translate(40,40)" fill="', _colors[3], '">',
        //                     '<animate attributeName="opacity" values="1;0.3;1" dur="9s" repeatCount="indefinite"/>',
        //                     '<animateTransform attributeName="transform" attributeType="XML" type="skewX" values="0;10;0;-10;0" dur="9s" repeatCount="indefinite" additive="sum"/>',
        //                     '<animateTransform attributeName="transform" attributeType="XML" type="skewY" values="0;25;0;-25;0" dur="9s" repeatCount="indefinite" additive="sum"/>',
        //                 '</use>',
        //             '</g>',
        //         '</defs>',
        //         '<rect width="100%" height="100%" />',
        //         '<g>',
        //             '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(0,0,0)"/>',
        //             '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(60,0,0)" />',
        //             '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(120,0,0)" />',
        //             '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(180,0,0)" />',
        //             '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(240,0,0)" />',
        //             '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(300,0,0)" />',
        //             '<animateTransform attributeName="transform" attributeType="XML" type="rotate" values="0 135 135;360 135 135" dur="30s" repeatCount="indefinite"/>',
        //         '</g>',
        //     '</svg>'));
        return string(abi.encodePacked(
            '<svg width="270" height="270" xmlns="http://www.w3.org/2000/svg" style="background-color:#121212">',
                '<defs>',
                    _mainPolygon,
                    '<g id="poly_group">',
                        '<use xlink:href="#poly" transform="matrix(0.77 0.81 -0.87 -0.33 0.86 0.84)" fill="', _colors[0], '"/>',
                        '<use xlink:href="#poly" transform="matrix(-0.81 0.41 0.65 0.26 0.3 -0.43) translate(40,0)" fill="', _colors[1], '"/>',
                        '<use xlink:href="#poly" transform="matrix(0.08 -0.36 -0.25 0.76 0.87 0.68) translate(0,40)" fill="', _colors[2], '"/>',
                        '<use xlink:href="#poly" transform="matrix(1.3 .2 .12 -0.23 -2.43 .13) translate(40,40)" fill="', _colors[3], '"/>',
                    '</g>',
                '</defs>',
                '<rect width="100%" height="100%" />',
                '<g>',
                    '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(0,0,0)"/>',
                    '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(60,0,0)" />',
                    '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(120,0,0)" />',
                    '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(180,0,0)" />',
                    '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(240,0,0)" />',
                    '<use xlink:href="#poly_group" transform="translate(135, 135) rotate(300,0,0)" />',
                '</g>',
            '</svg>'));
    }

    /**
     * @dev Generate polyline element based on seed
     *
     * @param seed The seed to generate the polyline from
     * @param seedModFactor The factor to mod the seed by
     *
     * Returns the SVG polyline element
     */
    function generatePolyline(uint seed, uint seedModFactor) internal pure returns (string memory, uint) {
        // Get number of sides for the polygon (between 3-6)
        seedModFactor += 1;
        uint _numberOfSides = 6;

        string memory _polyline = string(abi.encodePacked(
            '<polyline id="poly" points="0,0 '
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
        _polyline = string(abi.encodePacked(
            _polyline,
            ' 0,0" />' 
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
     * @dev Generate array of RGB color bassed on seed.
     *
     * @param seed The seed to generate the SVG art from
     * @param seedModFactor The factor to mod the seed by
     *
     * Returns the array RGB color strings
     */
    function generateColors(uint seed, uint seedModFactor) internal pure returns (string[4] memory, uint) {
        string[4] memory _colors;

        for (uint i = 0; i < 4; i++) {
            string memory _rgb;
            uint _polygonColorR;
            uint _polygonColorG;
            uint _polygonColorB;

            // Get the polygon color (between 0 and 255)
            seedModFactor += 1;
            _polygonColorR = seed % seedModFactor % 256;

            seedModFactor += 1;
            _polygonColorG = seed % seedModFactor % 256;

            seedModFactor += 1;
            _polygonColorB = seed % seedModFactor % 256;

            // Get the polygon color as string
            _rgb = string(abi.encodePacked(
                'rgb(',
                Strings.toString(_polygonColorR),
                ',',
                Strings.toString(_polygonColorG),
                ',',
                Strings.toString(_polygonColorB),
                ')'
            ));

            _colors[i] = _rgb;
        }

        return (_colors, seedModFactor);
    }
}