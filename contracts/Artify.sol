// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title On-chain generated SVG art based on seed phrase 
 * @author Utkarsh Sinha <sinha.karsh@gmail.com>
 */

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "./libraries/HSLGenerator.sol";
import "./libraries/SVGGenerator.sol";
import "./structs/HSL.sol";
import "./structs/ArtAttributes.sol";

contract Artify is ERC721, Ownable {
    mapping (uint256 => string) private _tokenSeed;
    mapping (uint256 => string) private _tokenArt;
    uint256 private _tokenID;
    uint256 private constant _MINT_FEE = 10000000000000000;

    constructor() public ERC721("Artify", "ARTIFY") {}

    /**
     * @dev Mints a new NFT token.
     *
     * Returns the token ID of the newly minted NFT.
     */
    function mintNFT(address minter, string calldata message) external payable returns (uint256)
    {
        require(msg.value >= _MINT_FEE, "Not enough ETH to mint");

        bytes memory messageBytes = bytes(message);
        require(messageBytes.length > 0, "No message provided");

        // Mint the token
        _tokenID += 1;
        _safeMint(minter, _tokenID);
        
        // Set the token's seed
        _tokenSeed[_tokenID] = message;

        // Generate token art
        _tokenArt[_tokenID] = SVGGenerator.generateArt(message);

        return _tokenID;
    }

    /**
     * @dev Generate contract metadata
     */
    function contractURI() public pure returns (string memory) {
        string memory contractImage = Base64.encode(bytes(SVGGenerator.generateContractImage()));

        return string(abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"Artify",',
                            '"description":"Permanently memorialize a message, quote, or any other text-based input on the blockchain.  Artify converts your input into a one-of-a-kind on-chain generated artwork that you can share with your friends, family, and the world.  Artify also allows you to gift your artwork to a friend or family member during the minting process. So if you wanna send that someone special a gift with a special message, Artify is the way to go! Art generated using Artify is permanently stored on the Ethereum blockchain, with no other server dependencies.",',
                            '"image":"data:image/svg+xml;base64,', contractImage, '",',
                            '"external_link": "https://artify.xyz"}'
                        )
                    )
                )
            ));
    }

    /**
     * @dev Withdraw the full ether balance in the contract
     */
    function withdrawFullBalance() payable external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @dev Generate custom SVG art based on token's seed.
     *
     * Returns the URI with "data:image/svg+xml;base64," prefix containing the SVG art.
     */
    function tokenURI(uint256 tokenID) public view override returns (string memory)
    {
        string memory seed = _tokenSeed[tokenID];
        bytes memory seedBytes = bytes(seed);
        require(seedBytes.length > 0, "TokenID not created yet");

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
        string memory seed = _tokenSeed[tokenID];
        bytes memory seedBytes = bytes(seed);
        require(seedBytes.length > 0, "TokenID not created yet");

        return _tokenArt[tokenID];
    }

    /**
     * @dev Generates metadata for NFT based on token's seed
     * @param seed The seed of the NFT
     */
    function generateTokenURI(string memory seed, uint tokenID) private view returns (string memory) {
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
                    '"trait_type":"Bezier Curve Count",',
                    '"value":"', Strings.toString(uint(artAttributes.numOfEdges)),'"',
                "},",
                "{",
                    '"trait_type":"Layer Count",',
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
                            '{"name":"Artify #', Strings.toString(tokenID), '",',
                            '"description":"', seed, '",',
                            '"image":"data:image/svg+xml;base64,', image, '",',
                            '"attributes":', attributes, '}'
                        )
                    )
                )
            )
        );
    }

}