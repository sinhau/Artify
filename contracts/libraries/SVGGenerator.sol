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

/**
 * @dev Utility functions for converting int to string
 * Returns string representation of int
 */
function intToString(int x) pure returns (string memory) {
    unchecked {
        return string(abi.encodePacked(x < 0 ? "-": "", Strings.toString(uint(x >=0 ? x : -x))));
    }
}

/**
 * @dev Utility functions that converts an int to a decimal with 2 significant digits
 * Returns string representation of decimal
 */
function intToStringDecimalTwoSigFigs(int x) pure returns (string memory decimal) {
    int whole = x / 100;
        
    int fractionInt = x % 100;
    uint fraction = uint(fractionInt >=0 ? fractionInt : -fractionInt);
    string memory fractionStr;
    if (fraction < 10) {
        fractionStr = string(abi.encodePacked("0",Strings.toString(fraction)));
    } else {
        fractionStr = Strings.toString(fraction);
    }

    decimal = string(abi.encodePacked(
        (x >= -99 && x < 0) ? "-": "",
        intToString(whole),
        ".",
        fractionStr
    ));
}

library SVGGenerator {
    /**
     * @dev Generate pseudo-random SVG art attributes based on the given seed
     * Returns an ArtAttributes struct
     */
    function generateArtAttributes(string memory seed) internal pure returns (ArtAttributes memory artAttributes, bytes32 newHashOfSeed) {
        bytes32 hashOfSeed = SeededRandomGenerator.init(seed);

        // Generate number of edges for the parent polygon
        int numOfEdges;
        (numOfEdges, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 4, 6);

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
     * @dev Generates an SVG polygon using the provided hash of seed
     * @param currentHashOfSeed The seed to use for generating the polygon
     * @param numOfEdges Number of edges in the polygon
     * @param id ID of the polygon element
     * @param min Minimum coordinate value of a polygon vertex
     * @param max Maximum coordinate value of a polygon vertex
     * Returns an SVG polygon element as a string
     */
    function generatePolygon(bytes32 currentHashOfSeed, uint numOfEdges, string memory id, int min, int max) internal pure returns (string memory polygon, bytes32 newHashOfSeed) {
        // Generate all the vertices of the polygon
        string[] memory points = new string[](numOfEdges - 1);
        for (uint i = 0; i < numOfEdges - 1; i++) {
            int x;
            int y;
            (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
            (y, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
            points[i] = string(abi.encodePacked(intToString(x), ",", intToString(y)));
        }

        // Update the hash of the seed
        newHashOfSeed = currentHashOfSeed;

        // Assemble the polygon SVG element
        string memory polygon_points = "0,0 ";
        for (uint i = 0; i < numOfEdges - 1; i++) {
            polygon_points = string(abi.encodePacked(polygon_points, points[i], " "));
        }
        polygon_points = string(abi.encodePacked(polygon_points, "0,0"));
        polygon = string(abi.encodePacked(
            "<polyline id='", id, "' ",
            "points='", polygon_points, "' />"
        ));
    }

    /**
     * @dev Generate a transform matrix 
     * @param currentHashOfSeed The seed to use for generating the circle
     * @param min Int representing min transform value in 2 sig figs (e.g. -400 = -4.00)
     * @param max Int representing max transform value in 2 sig figs (e.g. 65 = 0.65)
     * Returns a transform matrix as a string
     */
    function generateMatrixTransform(bytes32 currentHashOfSeed, int min, int max) internal pure returns (string memory transformMatrix, bytes32 newHashOfSeed) {
        transformMatrix = "matrix(";
        for (uint i = 0; i < 6; i++) {
            int x;
            (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
            transformMatrix = string(abi.encodePacked(transformMatrix, intToStringDecimalTwoSigFigs(x), (i == 5) ? "": " "));
        }
        transformMatrix = string(abi.encodePacked(transformMatrix, ")"));

        newHashOfSeed = currentHashOfSeed;
    }

    /**
     * @dev Generate a translate transformation
     * @param currentHashOfSeed The seed to use for generating the circle
     * @param minX Min translate x value
     * @param maxX Max translate x value
     * @param minY Min translate y value
     * @param maxY Max translate y value
     * Returns a translate transformation as a string
     */
    function generateTranslate(bytes32 currentHashOfSeed, int minX, int maxX, int minY, int maxY) internal pure returns (string memory translate, bytes32 newHashOfSeed) {
        int x;
        int y;
        (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, minX, maxX);
        (y, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, minY, maxY);
        translate = string(abi.encodePacked(
            "translate(", intToString(x), ",", intToString(y), ")"
        ));

        newHashOfSeed = currentHashOfSeed;
    }

    /**
     * @dev Generate a animate SVG element
     * @param attributeName The attribute to animate
     * @param values An string of values to animate to
     * @param dur Duration of the animation
     * Returns an animate SVG element as a string
     */
    function generateAnimate(string memory attributeName, string memory values, int dur) internal pure returns (string memory animate) {
        animate = string(abi.encodePacked(
            "<animate attributeName='", attributeName, "' values='", values, "' dur='", intToString(dur), "s' repeatCount='indefinite'/>"
        ));
    }

    /**
     * @dev Generate a animateTransform SVG element
     * @param input Input contaning AnimateTransformInputs type
     * Returns an animate SVG element as a string
     */
    function generateAnimateTransform(AnimateTransformInputs memory input) internal pure returns (string memory animate) {
        animate = string(abi.encodePacked(
            "<animateTransform attributeName='", input.attributeName, "' attributeType='", input.attributeType, "' type='", input.typeOfTransform, "' values='", input.values, "' dur='", intToString(input.dur), "s' repeatCount='indefinite' additive='sum'/>"
        ));
    }

    /**
     * @dev Generate a polygon group element
     * @param currentHashOfSeed The seed to use for generating the polygon group params
     * @param id ID of the parent polygon group element
     * @param color HSL color for the polygon group
     * @param polygonIndex Index of the polygon in the group
     */
    function generatePolygonGroup(bytes32 currentHashOfSeed, string memory id, HSL memory color, uint polygonIndex) internal pure returns (string memory polygonGroup, bytes32 newHashOfSeed) {
        polygonGroup = string(abi.encodePacked("<use xlink:href='#", id, "' transform='"));

        // Generate transform matrix
        string memory transformMatrix;
        (transformMatrix, currentHashOfSeed) = generateMatrixTransform(currentHashOfSeed, -100, 100);

        // Generate translate transformation
        string memory translate;
        if (polygonIndex == 1) {
            translate = "translate(0,0)";
        } else if (polygonIndex == 2) {
            (translate, currentHashOfSeed) = generateTranslate(currentHashOfSeed, 30, 40, 0, 10);
        } else if (polygonIndex == 3) {
            (translate, currentHashOfSeed) = generateTranslate(currentHashOfSeed, 0, 10, 30, 40);
        } else {
            (translate, currentHashOfSeed) = generateTranslate(currentHashOfSeed, 10*int(polygonIndex), 10*int(polygonIndex) + 10, 10*int(polygonIndex), 10*int(polygonIndex) + 10);
        }

        polygonGroup = string(abi.encodePacked(polygonGroup, transformMatrix, " ", translate,"' fill='", HSLGenerator.toString(color), "' >"));

        // Generate animations
        string memory animate = generateAnimate("opacity", "1;0.3;1", 2 * int(polygonIndex));

        int skewFactor;
        (skewFactor, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, 7, 12);
        int dur = 2 * int(polygonIndex);

        string memory animateTransformX;
        string memory animateTransformXValues;
        animateTransformXValues = string(abi.encodePacked(
            "0;",
            intToString(skewFactor * int(polygonIndex)),";",
            "0;",
            intToString(-skewFactor * int(polygonIndex)),";",
            "0"
        ));
        AnimateTransformInputs memory input = AnimateTransformInputs(
            "transform",
            "XML",
            "skewX",
            animateTransformXValues,
            dur
        );
        animateTransformX = generateAnimateTransform(input);

        string memory animateTransformY;
        string memory animateTransformYValues;
        animateTransformYValues = string(abi.encodePacked(
            "0;",
            intToString(-skewFactor * int(polygonIndex)),";",
            "0;",
            intToString(skewFactor * int(polygonIndex)),";",
            "0"
        ));
        input = AnimateTransformInputs(
            "transform",
            "XML",
            "skewY",
            animateTransformYValues,
            dur
        );
        animateTransformY = generateAnimateTransform(input);

        polygonGroup = string(abi.encodePacked(
            polygonGroup,
            animate,
            animateTransformX,
            animateTransformY,
             "</use>"
        ));

        newHashOfSeed = currentHashOfSeed;
    }
}