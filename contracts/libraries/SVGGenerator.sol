// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Utility functions for generating various SVG elements
 * @author Utkarsh Sinha <sinha.karsh@gmail.com>
 */

import "./SeededRandomGenerator.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./HSLGenerator.sol";
import "../structs/AnimateTransformInputs.sol";
import "../structs/ArtAttributes.sol";
import "./StringConversions.sol";

library SVGGenerator {
    /**
     * @dev Generate custom SVG art based on token's seed.
     * @param seed The seed to generate the SVG art from
     * Returns the SVG image as bytes
     */
    function generateArt(string memory seed) external pure returns (string memory) {
        ArtAttributes memory artAttributes;
        bytes32 hashOfSeed;
        (artAttributes, hashOfSeed) = generateArtAttributes(seed);

        // Generate SVG element for the main polygon
        string memory parentPolygon;
        string memory parentPolygonID = "parentPolygon";
        (parentPolygon, hashOfSeed) = generatePath(hashOfSeed, uint(artAttributes.numOfEdges), parentPolygonID, -80, 80);

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
            (polygon, hashOfSeed) = generatePolygonGroup(hashOfSeed, parentPolygonID, HSLColors[i-1], i);
            polygonGroups = string(abi.encodePacked(
                polygonGroups,
                polygon
            ));
        }
        polygonGroups = string(abi.encodePacked(polygonGroups, "</g>"));


        // Assemble SVG
        return string(abi.encodePacked(
            "<svg version='1.1' width='640' height='640' viewbox='0 0 640 640' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' style='background-color:hsl(0, 100%, 0%)'>",
                "<metadata>",
                    "<message>",
                        seed,
                    "</message>",
                    "<contract>",
                        "Artify: Permanently memorialize a message, quote, or any other text-based input on the blockchain.  Artify converts your input into a one-of-a-kind on-chain generated artwork that you can share with your friends, family, and the world. Created by karsh.eth"
                    "</contract>",
                "</metadata>",
                "<defs>",
                    "<filter id='blendSoft' x='-50%' y='-50%' width='200%' height='200%'><feGaussianBlur in='SourceGraphic' stdDeviation='5' /></filter>",
                    "<filter id='blendHard'><feGaussianBlur in='SourceGraphic' stdDeviation='1' /></filter>",
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
                    "<animateTransform attributeName='transform' attributeType='XML' type='rotate' values='0 320 320;360 320 320' dur='20s' repeatCount='indefinite'/>",
                "</g>",
            "</svg>"));
    }
   
    /**
     * @dev Generate pseudo-random SVG art attributes based on the given seed
     * Returns an ArtAttributes struct
     */
    function generateArtAttributes(string memory seed) public pure returns (ArtAttributes memory artAttributes, bytes32 newHashOfSeed) {
        bytes32 hashOfSeed = SeededRandomGenerator.init(seed);

        // Generate number of edges for the parent polygon
        int numOfEdges;
        (numOfEdges, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 1, 2);

        // Generate number of polygon layers to use
        int numOfPolygonGroups;
        (numOfPolygonGroups, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 3, 5);

        // Generate color scheme
        int colorScheme;
        (colorScheme, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 1, 3);

        // Generate root HSL values
        int rootHue;
        (rootHue, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 0, 359);
        int rootSaturation;
        (rootSaturation, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 80, 100);
        int rootLightness;
        (rootLightness, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 30, 50);

        artAttributes.numOfEdges = numOfEdges;
        artAttributes.numOfPolygonGroups = numOfPolygonGroups;
        artAttributes.colorScheme = colorScheme;
        artAttributes.rootHue = rootHue;
        artAttributes.rootSaturation = rootSaturation;
        artAttributes.rootLightness = rootLightness;

        newHashOfSeed = hashOfSeed;
    }

    /**
     * @dev Generates an SVG path element using the provided hash of seed
     * @param currentHashOfSeed The seed to use for generating the polygon
     * @param numOfCurves Number of curves to use
     * @param id ID of the polygon element
     * @param min Minimum coordinate value of a control point vertex
     * @param max Maximum coordinate value of a control point vertex
     * Returns an SVG polygon element as a string
     */
    function generatePath(bytes32 currentHashOfSeed, uint numOfCurves, string memory id, int min, int max) private pure returns (string memory path, bytes32 newHashOfSeed) {
        path = string(abi.encodePacked(
            "<path id='", id, "' d='M 0 0 "
        ));

        int x;
        int y;
        for (uint i = 0; i < numOfCurves; i++) {
            if (i == 0) {
                (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
                (y, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min/2, max/2);
                path = string(abi.encodePacked(
                    path,
                    "C ", StringConversions.int256ToString(x), " ", StringConversions.int256ToString(y), ", "
                ));

                (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
                (y, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min/2, max/2);
                path = string(abi.encodePacked(
                    path,
                    StringConversions.int256ToString(x), " ", StringConversions.int256ToString(y), ", "
                ));

                (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
                (y, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min/2, max/2);
                path = string(abi.encodePacked(
                    path,
                    StringConversions.int256ToString(x), " ", StringConversions.int256ToString(y), " "
                ));
            } else {
                (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
                (y, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min/2, max/2);
                path = string(abi.encodePacked(
                    path,
                    "S ", StringConversions.int256ToString(x), " ", StringConversions.int256ToString(y), ", "
                ));

                (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
                (y, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min/2, max/2);
                path = string(abi.encodePacked(
                    path,
                    StringConversions.int256ToString(x), " ", StringConversions.int256ToString(y), " "
                ));
            }
        }
        (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
        (y, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min/2, max/2);
        path = string(abi.encodePacked(
            path,
            "S ", StringConversions.int256ToString(x), " ", StringConversions.int256ToString(y), ", "
        ));
        path = string(abi.encodePacked(
            path,
            "0 0' />"
        ));

        // Update the hash of the seed
        newHashOfSeed = currentHashOfSeed;
    }

    /**
     * @dev Generate a transform matrix 
     * @param currentHashOfSeed The seed to use for generating the circle
     * @param min Int representing min transform value in 2 sig figs (e.g. -400 = -4.00)
     * @param max Int representing max transform value in 2 sig figs (e.g. 65 = 0.65)
     * Returns a transform matrix as a string
     */
    function generateMatrixTransform(bytes32 currentHashOfSeed, int min, int max) private pure returns (string memory transformMatrix, bytes32 newHashOfSeed) {
        transformMatrix = "matrix(";
        int x;
        for (uint i = 0; i < 6; i++) {
            (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
            transformMatrix = string(abi.encodePacked(transformMatrix, StringConversions.decimalTwoSigFigsToStrings(x), (i == 5) ? "": " "));
        }
        transformMatrix = string(abi.encodePacked(transformMatrix, ")"));

        newHashOfSeed = currentHashOfSeed;
    }

    /**
     * @dev Generate a animate SVG element
     * @param attributeName The attribute to animate
     * @param values An string of values to animate to
     * @param dur Duration of the animation
     * Returns an animate SVG element as a string
     */
    function generateAnimate(string memory attributeName, string memory values, int dur) private pure returns (string memory animate) {
        animate = string(abi.encodePacked(
            "<animate attributeName='", attributeName, "' values='", values, "' dur='", StringConversions.int256ToString(dur), "s' repeatCount='indefinite'/>"
        ));
    }

    /**
     * @dev Generate a animateTransform SVG element
     * @param input Input contaning AnimateTransformInputs type
     * Returns an animate SVG element as a string
     */
    function generateAnimateTransform(AnimateTransformInputs memory input) private pure returns (string memory animate) {
        animate = string(abi.encodePacked(
            "<animateTransform attributeName='", input.attributeName, "' attributeType='", input.attributeType, "' type='", input.typeOfTransform, "' values='", input.values, "' dur='", StringConversions.int256ToString(input.dur), "s' repeatCount='indefinite' additive='sum'/>"
        ));
    }

    /**
     * @dev Generate a polygon group element
     * @param currentHashOfSeed The seed to use for generating the polygon group params
     * @param id ID of the parent polygon group element
     * @param color HSL color for the polygon group
     * @param polygonIndex Index of the polygon in the group
     */
    function generatePolygonGroup(bytes32 currentHashOfSeed, string memory id, HSL memory color, uint polygonIndex) private pure returns (string memory polygonGroup, bytes32 newHashOfSeed) {
        polygonGroup = string(abi.encodePacked("<use xlink:href='#", id, "' "));

        // Generate transform matrix
        if (polygonIndex != 1) {
            string memory transformMatrix;
            (transformMatrix, currentHashOfSeed) = generateMatrixTransform(currentHashOfSeed, -150, 150);

            polygonGroup = string(abi.encodePacked(
                polygonGroup, "transform='", transformMatrix, "' "
            ));
        }
        polygonGroup = string(abi.encodePacked(
            polygonGroup,
            "fill='", HSLGenerator.toString(color), "' "
        ));

        // Add blend filter
        if (polygonIndex % 2 != 0) {
            polygonGroup = string(abi.encodePacked(
                polygonGroup,
                "filter='url(#blendHard)' >"
            ));
        } else {
            polygonGroup = string(abi.encodePacked(
                polygonGroup,
                "filter='url(#blendSoft)' >"
            ));
        }

        // Generate animations
        string memory animate = generateAnimate("opacity", "1;0.3;1", 2 * int(polygonIndex));

        int translateFactor;
        (translateFactor, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, 100,200);
        int dur;
        (dur, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, 5, 20);
        // int dur = 10 * int(polygonIndex);

        string memory animateTransformX;
        string memory animateTransformXValues;
        animateTransformXValues = string(abi.encodePacked(
            "0;",
            StringConversions.int256ToString(translateFactor),";",
            "0;"
        ));
        AnimateTransformInputs memory input = AnimateTransformInputs(
            "transform",
            "XML",
            "translateX",
            animateTransformXValues,
            dur
        );
        animateTransformX = generateAnimateTransform(input);

        polygonGroup = string(abi.encodePacked(
            polygonGroup,
            animate,
            animateTransformX,
             "</use>"
        ));

        newHashOfSeed = currentHashOfSeed;
    }
}