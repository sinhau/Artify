// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title On-chain generated SVG art based on seed phrase
 * @author Utkarsh Sinha <sinha.karsh@gmail.com>
 */

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "base64-sol/base64.sol";
import "./libraries/HSLGenerator.sol";
import "./libraries/SVGGenerator.sol";
import "./libraries/StringConversions.sol";
import "./structs/HSL.sol";
import "./structs/ArtAttributes.sol";

contract Artify is ERC721, Ownable {
    using Counters for Counters.Counter;

    mapping(uint256 => string) private _tokenSeed;
    mapping(address => int) private _hasWalletAvatar;
    mapping(address => bool) public whitelist;
    Counters.Counter _tokenID;
    uint256 public constant MINT_FEE = 10000000000000000; //Default mint fee of 0.01 ETH
    uint256 public publicSaleStartTime = 1645084801; // Feb 17, 2022 @ 12:00:01 AM (PST)
    bool public isSalePaused = false;

    constructor() public ERC721("Artify", "ARTIFY") {}

    /**
     * @dev Mints a new NFT token.
     *
     * Returns the token ID of the newly minted NFT.
     */
    function mintWalletAvatar() external payable {
        require(_hasWalletAvatar[msg.sender] == 0, "Wallet already has an avatar");
        _hasWalletAvatar[msg.sender] = 1;

        // Whitelisted addresses don't need to pay mint fee
        // and they can mint anytime
        if (whitelist[msg.sender] == false) {
            require(msg.value >= MINT_FEE, "Not enough ETH to mint");
            require(
                block.timestamp >= publicSaleStartTime,
                "Cannot mint NFT before public sale starts"
            );
        }

        require(!isSalePaused, "Cannot mint NFT while the sale is paused");

        // bytes memory messageBytes = bytes(message);
        // require(messageBytes.length > 0, "No message provided");

        _tokenID.increment();
        uint256 tokenID = _tokenID.current();

        // Mint the token
        _safeMint(msg.sender, tokenID);
    }

    /**
     * @dev Mint an NFT based on provided message as seed
     * @param seed The seed phrase to generate the NFT
     */
    function mintMessage(string memory seed) external payable {
        // Whitelisted addresses don't need to pay mint fee
        // and they can mint anytime
        if (whitelist[msg.sender] == false) {
            require(msg.value >= MINT_FEE, "Not enough ETH to mint");
            require(
                block.timestamp >= publicSaleStartTime,
                "Cannot mint NFT before public sale starts"
            );
        }

        require(!isSalePaused, "Cannot mint NFT while the sale is paused");

        bytes memory messageBytes = bytes(seed);
        require(messageBytes.length > 0, "No message provided");

        _tokenID.increment();
        uint256 tokenID = _tokenID.current();

        _tokenSeed[tokenID] = seed;

        // Mint the token
        _safeMint(msg.sender, tokenID);
    }

    /**
     * @dev Sets the sale pause status
     */
    function setSalePauseStatus(bool pause) external onlyOwner returns (bool) {
        isSalePaused = pause;
        return isSalePaused;
    }

    /**
     * @dev Update whitelist status of the given address
     */
    function updateWhitelistStatus(address addr, bool status)
        external
        onlyOwner
    {
        whitelist[addr] = status;
    }

    /**
     * @dev Change publicSaleStartTime by the provided epoch time in seconds
     */
    function changeSaleStartTime(uint256 newSaleTime)
        external
        onlyOwner
        returns (uint256)
    {
        publicSaleStartTime = newSaleTime;
        return publicSaleStartTime;
    }

    /**
     * @dev Generate contract metadata
     */
    function contractURI() public pure returns (string memory) {
        string memory contractImage = Base64.encode(
            bytes(SVGGenerator.generateArt("Artify by karsh.eth"))
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"Artify",',
                                '"description":"Permanently memorialize a message, quote, or any other text-based input on the blockchain.  Artify converts your input into a one-of-a-kind on-chain generated artwork that you can share with your friends, family, and the world.  Artify also allows you to gift your artwork to a friend or family member during the minting process. So if you wanna send that someone special a gift with a special message, Artify is the way to go! Art generated using Artify is permanently stored on the Ethereum blockchain, with no other server dependencies.",',
                                '"image":"data:image/svg+xml;base64,',
                                contractImage,
                                '",',
                                '"external_link": "https://artify.xyz"}'
                            )
                        )
                    )
                )
            );
    }

    /**
     * @dev Withdraw the full ether balance in the contract
     */
    function withdrawFullBalance() external payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @dev Generate custom SVG art based on token's seed.
     *
     * Returns the URI with "data:image/svg+xml;base64," prefix containing the SVG art.
     */
    function tokenURI(uint256 tokenID)
        public
        view
        override
        returns (string memory)
    {
        require(tokenID <= _tokenID.current(), "TokenID not created yet");

        string memory seed = _tokenSeed[tokenID];
        bytes memory seedBytes = bytes(seed);
        string memory input;
        if (seedBytes.length == 0) {
            input = StringConversions.addressToString(this.ownerOf(tokenID));
        } else {
            input = seed;
        }

        string memory _tokenURI = generateTokenURI(input, tokenID);
        return _tokenURI;
    }

    /**
     * @dev Get SVG art based on token's seed.
     *
     * @param tokenID The seed to generate art from
     *
     * Returns SVG art as XML formatted string.
     */
    function getArt(uint256 tokenID) external view returns (string memory) {
        require(tokenID <= _tokenID.current(), "TokenID not created yet");

        string memory seed = _tokenSeed[tokenID];
        bytes memory seedBytes = bytes(seed);
        string memory input;
        if (seedBytes.length == 0) {
            input = StringConversions.addressToString(this.ownerOf(tokenID));
        } else {
            input = seed;
        }

        return SVGGenerator.generateArt(input);
    }

    /**
     * @dev Generates metadata for NFT based on token's seed
     * @param seed The seed of the NFT
     */
    function generateTokenURI(string memory seed, uint256 tokenID)
        private
        pure
        returns (string memory)
    {
        string memory image = SVGGenerator.generateArt(seed);

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

        HSL memory hsl = HSL(
            uint256(artAttributes.rootHue),
            uint256(artAttributes.rootSaturation),
            uint256(artAttributes.rootLightness)
        );

        // Assemble attributes string
        string memory attributes = "";
        attributes = string(
            abi.encodePacked(
                "[",
                "{",
                '"trait_type":"Bezier Curve Count",',
                '"value":"',
                Strings.toString(uint256(artAttributes.numOfEdges)),
                '"',
                "},",
                "{",
                '"trait_type":"Layer Count",',
                '"value":"',
                Strings.toString(uint256(artAttributes.numOfPolygonGroups)),
                '"',
                "},",
                "{",
                '"trait_type":"Color Scheme",',
                '"value":"',
                colorScheme,
                '"',
                "},",
                "{",
                '"trait_type":"Root HSL",',
                '"value":"',
                HSLGenerator.toString(hsl),
                '"',
                "}",
                "]"
            )
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"Artify #',
                                Strings.toString(tokenID),
                                '",',
                                '"description":"',
                                seed,
                                '",',
                                '"image":"data:image/svg+xml;base64,',
                                Base64.encode(bytes(image)),
                                '",',
                                '"attributes":',
                                attributes,
                                "}"
                            )
                        )
                    )
                )
            );
    }
}
