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
     * @dev Predefined image for the contract metadata
     */
    function generateContractImage() external pure returns (string memory image) {
        image = string(abi.encodePacked(
            "<svg version='1.1' width='640' height='640' viewbox='0 0 640 640' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' style='background-color:hsl(0, 100%, 0%)'><metadata><message>Artsy Messages: On-chain generated SVG art encoding a secret message from the minter - 0xdd175a204142040850211b529dcb9af6ee743e1b</message></metadata><defs><path id='parentPolygon' d='M 0 0 C 43 24, 0 -12, 42 -21 S 57 19, 3 20 S -13 8, 0 0' stroke='hsl(0,0%,40%)' /><g id='polygonGroups'><use xlink:href='#parentPolygon' transform='matrix(-0.79 -0.97 -0.62 -0.33 0.08 -0.12)' fill='hsl(320,96%,50%)' ><animate attributeName='opacity' values='1;0.3;1' dur='2s' repeatCount='indefinite'/><animateTransform attributeName='transform' attributeType='XML' type='translateX' values='0;69;0;' dur='25s' repeatCount='indefinite' additive='sum'/></use><use xlink:href='#parentPolygon' transform='matrix(0.92 0.76 -0.53 0.70 -0.06 0.20)' fill='hsl(350,96%,50%)' ><animate attributeName='opacity' values='1;0.3;1' dur='4s' repeatCount='indefinite'/><animateTransform attributeName='transform' attributeType='XML' type='translateX' values='0;56;0;' dur='20s' repeatCount='indefinite' additive='sum'/></use><use xlink:href='#parentPolygon' transform='matrix(-0.43 -0.36 -0.71 0.10 0.36 0.46)' fill='hsl(20,96%,50%)' ><animate attributeName='opacity' values='1;0.3;1' dur='6s' repeatCount='indefinite'/><animateTransform attributeName='transform' attributeType='XML' type='translateX' values='0;140;0;' dur='6s' repeatCount='indefinite' additive='sum'/></use><use xlink:href='#parentPolygon' transform='matrix(0.75 -0.52 -0.10 0.75 0.09 0.08)' fill='hsl(20,96%,50%)' ><animate attributeName='opacity' values='1;0.3;1' dur='8s' repeatCount='indefinite'/><animateTransform attributeName='transform' attributeType='XML' type='translateX' values='0;87;0;' dur='13s' repeatCount='indefinite' additive='sum'/></use><use xlink:href='#parentPolygon' transform='matrix(-0.38 1.00 -0.92 -0.95 0.05 -0.19)' fill='hsl(50,96%,50%)' ><animate attributeName='opacity' values='1;0.3;1' dur='10s' repeatCount='indefinite'/><animateTransform attributeName='transform' attributeType='XML' type='translateX' values='0;103;0;' dur='18s' repeatCount='indefinite' additive='sum'/></use></g></defs><rect width='100%' height='100%' fill='hsl(0, 100%, 0%)'/><g><use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(0,0,0)'/><use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(60,0,0)' /><use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(120,0,0)' /><use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(180,0,0)' /><use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(240,0,0)' /><use xlink:href='#polygonGroups' transform='translate(320, 320) rotate(300,0,0)' /><animateTransform attributeName='transform' attributeType='XML' type='rotate' values='0 320 320;360 320 320' dur='20s' repeatCount='indefinite'/></g></svg>"
        ));
    }
   
    /**
     * @dev Generate pseudo-random SVG art attributes based on the given seed
     * Returns an ArtAttributes struct
     */
    function generateArtAttributes(string memory seed) external pure returns (ArtAttributes memory artAttributes, bytes32 newHashOfSeed) {
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
    function generatePath(bytes32 currentHashOfSeed, uint numOfCurves, string memory id, int min, int max) external pure returns (string memory path, bytes32 newHashOfSeed) {
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
            "0 0' stroke='hsl(0,0%,40%)' />"
        ));

        // Update the hash of the seed
        newHashOfSeed = currentHashOfSeed;
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
    function generatePolygon(bytes32 currentHashOfSeed, uint numOfEdges, string memory id, int min, int max) external pure returns (string memory polygon, bytes32 newHashOfSeed) {
        // Generate all the vertices of the polygon
        string[] memory points = new string[](numOfEdges - 1);
        int x;
        int y;
        for (uint i = 0; i < numOfEdges - 1; i++) {
            (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
            (y, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, min, max);
            points[i] = string(abi.encodePacked(StringConversions.int256ToString(x), ",", StringConversions.int256ToString(y)));
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
     * @dev Generate a translate transformation
     * @param currentHashOfSeed The seed to use for generating the circle
     * @param minX Min translate x value
     * @param maxX Max translate x value
     * @param minY Min translate y value
     * @param maxY Max translate y value
     * Returns a translate transformation as a string
     */
    function generateTranslate(bytes32 currentHashOfSeed, int minX, int maxX, int minY, int maxY) private pure returns (string memory translate, bytes32 newHashOfSeed) {
        int x;
        int y;
        (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, minX, maxX);
        (y, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, minY, maxY);
        translate = string(abi.encodePacked(
            "translate(", StringConversions.int256ToString(x), ",", StringConversions.int256ToString(y), ")"
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
    function generatePolygonGroup(bytes32 currentHashOfSeed, string memory id, HSL memory color, uint polygonIndex) external pure returns (string memory polygonGroup, bytes32 newHashOfSeed) {
        polygonGroup = string(abi.encodePacked("<use xlink:href='#", id, "' "));

        // Generate transform matrix
        if (polygonIndex != 1) {
            string memory transformMatrix;
            (transformMatrix, currentHashOfSeed) = generateMatrixTransform(currentHashOfSeed, -100, 100);

            polygonGroup = string(abi.encodePacked(
                polygonGroup, "transform='", transformMatrix, "' "
            ));
        }
        polygonGroup = string(abi.encodePacked(
            polygonGroup,
            "fill='", HSLGenerator.toString(color), "' >"
        ));

        // Generate animations
        string memory animate = generateAnimate("opacity", "1;0.3;1", 2 * int(polygonIndex));

        int translateFactor;
        (translateFactor, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, 100,250);
        int dur;
        (dur, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, 5, 30);
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