// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Utility functions for generating various SVG elements
 * @author Utkarsh Sinha <sinha.karsh@gmail.com>
 */

import "./SeededRandomGenerator.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./HSLGenerator.sol";

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
            (translate, currentHashOfSeed) = generateTranslate(currentHashOfSeed, 0, 10, 0, 10);
        } else if (polygonIndex == 2) {
            (translate, currentHashOfSeed) = generateTranslate(currentHashOfSeed, 15, 30, 0, 10);
        } else if (polygonIndex == 3) {
            (translate, currentHashOfSeed) = generateTranslate(currentHashOfSeed, 0, 10, 15, 30);
        } else {
            (translate, currentHashOfSeed) = generateTranslate(currentHashOfSeed, 10*int(polygonIndex), 10*int(polygonIndex) + 20, 10*int(polygonIndex), 10*int(polygonIndex) + 20);
        }

        polygonGroup = string(abi.encodePacked(polygonGroup, transformMatrix, " ", translate,"' fill='", HSLGenerator.toString(color), "' >"));

        // Generate animations

        polygonGroup = string(abi.encodePacked(polygonGroup, "</use>"));

        // string memory polygon;
        // (polygon, currentHashOfSeed) = generatePolygon(currentHashOfSeed, 6, id, -400, 65);

        // polygonGroup = string(abi.encodePacked(
        //     "<g id='", id, "' ",
        //     "transform='", transformMatrix, "' ",
        //     "fill='", color, "'>",
        //     polygon,
        //     "</g>"
        // ));

        newHashOfSeed = currentHashOfSeed;
    }
}