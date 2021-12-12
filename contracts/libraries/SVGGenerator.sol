// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Utility functions for generating various SVG elements
 * @author Utkarsh Sinha <sinha.karsh@gmail.com>
 */

import "./SeededRandomGenerator.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @dev Utility functions for converting int to string
 * Returns string representation of int
 */
function intToString(int x) pure returns (string memory) {
    unchecked {
        return string(abi.encodePacked(x <= 0 ? "-": "", Strings.toString(uint(x >=0 ? x : -x))));
    }
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
}