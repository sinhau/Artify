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

library SVGGenerator {
    /**
     * @dev Generate pseudo-random SVG art attributes based on the given seed
     * Returns an ArtAttributes struct
     */
    function generateArtAttributes(string memory seed) external pure returns (ArtAttributes memory artAttributes, bytes32 newHashOfSeed) {
        bytes32 hashOfSeed = SeededRandomGenerator.init(seed);

        // Generate number of control points for parent path
        int numControlPoints;
        (numControlPoints, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 3, 6);

        // Generate number of layers to use
        int numOfLayers;
        (numOfLayers, hashOfSeed) = SeededRandomGenerator.randomInt(hashOfSeed, 3, 5);

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

        artAttributes.numControlPoints = numControlPoints;
        artAttributes.numOfLayers = numOfLayers;
        artAttributes.colorScheme = colorScheme;
        artAttributes.rootHue = rootHue;
        artAttributes.rootSaturation = rootSaturation;
        artAttributes.rootLightness = rootLightness;

        newHashOfSeed = hashOfSeed;
    }

    /**
     * @dev Generate a SVG path element
     * @param currentHashOfSeed The current hash of the seed
     * @param id The id of the path element
     * @param numControlPoints Number of control points to use
     * @param minX Minimum X value
     * @param maxX Maximum X value
     * @param minY Minimum Y value
     * @param maxY Maximum Y value
     * Returns a string containing the SVG path
     */
    function generatePath(bytes32 currentHashOfSeed, string memory id, int numControlPoints, int minX, int maxX, int minY, int maxY) external pure returns (string memory svgPath, bytes32 newHashOfSeed) {
        string memory svgPathDAttributeStart;
        (svgPathDAttributeStart, currentHashOfSeed) = generatePathDAttribute(currentHashOfSeed, numControlPoints, minX, maxX, minY, maxY);

        string memory svgPathDAttribute;
        (svgPathDAttribute, currentHashOfSeed) = generatePathDAttribute(currentHashOfSeed, numControlPoints, minX, maxX, minY, maxY);

        svgPath = string(abi.encodePacked(
            "<path id='", id, "' d='", svgPathDAttributeStart, "' stroke='hsl(0,0%,40%)'>",
            "<animate attributeType='XML' attributeName='d' values='",
            svgPathDAttributeStart, ";", svgPathDAttribute, ";", svgPathDAttributeStart, "' dur='10s' repeatCount='indefinite' />",
            "</path>"
        ));


        newHashOfSeed = currentHashOfSeed;
    }

    /**
     * @dev Generates a SVG path's d attribute containing bezier curves
     * @param currentHashOfSeed The seed to use for generating the polygon
     * @param numControlPoints The number of control points to use
     * @param minX The minimum x value to use for the control points
     * @param maxX The maximum x value to use for the control points
     * @param minY The minimum y value to use for the control points
     * @param maxY The maximum y value to use for the control points
     */
    function generatePathDAttribute(bytes32 currentHashOfSeed, int numControlPoints, int minX, int maxX, int minY, int maxY) private pure returns (string memory d, bytes32 newHashOfSeed) {
        // Generate control points
        d = "M 0 0 ";
        string memory controlPoints;
        for (int i = 0; i < numControlPoints; i++) {
            if (i == 0) {
                (controlPoints, currentHashOfSeed) = generateControlPointCType(currentHashOfSeed, minX, maxX, minY, maxY);
            } else {
                (controlPoints, currentHashOfSeed) = generateControlPointSType(currentHashOfSeed, minX, maxX, minY, maxY);
            }
            d = string(abi.encodePacked(
                d,
                controlPoints
            ));
        }
        string memory tempControlPoint;
        (tempControlPoint, currentHashOfSeed) = generateControlPoint(currentHashOfSeed, minX, maxX, minY, maxY);
        d = string(abi.encodePacked(
            d,
            "S ",
            tempControlPoint, ",",
            " 0 0"
        ));

        newHashOfSeed = currentHashOfSeed;
    }

    /**
     * @dev Generate a C type bezier curve control point
     * @param currentHashOfSeed The seed to use for generating the control point
     * @param minX The minimum x value to use for the control point
     * @param minY The minimum y value to use for the control point
     * @param maxX The maximum x value to use for the control point
     * @param maxY The maximum y value to use for the control point
     */
    function generateControlPointCType(bytes32 currentHashOfSeed, int minX, int maxX, int minY, int maxY) private pure returns (string memory controlPointCType, bytes32 newHashOfSeed) {
        controlPointCType = "C ";
        string memory controlPoint;
        for (uint i = 0; i < 3; i++) {
            (controlPoint, currentHashOfSeed) = generateControlPoint(currentHashOfSeed, minX, maxX, minY, maxY);
            controlPointCType = string(abi.encodePacked(
                controlPointCType,
                controlPoint,
                (i == 2) ? " " : ", "
            ));
        }
        newHashOfSeed = currentHashOfSeed;
    }

    /**
     * @dev Generate a S type bezier curve control point
     * @param currentHashOfSeed The seed to use for generating the control point
     * @param minX The minimum x value to use for the control point
     * @param minY The minimum y value to use for the control point
     * @param maxX The maximum x value to use for the control point
     * @param maxY The maximum y value to use for the control point
     */
    function generateControlPointSType(bytes32 currentHashOfSeed, int minX, int maxX, int minY, int maxY) private pure returns (string memory controlPointSType, bytes32 newHashOfSeed) {
        controlPointSType = "S ";
        string memory controlPoint;
        for (uint i = 0; i < 2; i++) {
            (controlPoint, currentHashOfSeed) = generateControlPoint(currentHashOfSeed, minX, maxX, minY, maxY);
            controlPointSType = string(abi.encodePacked(
                controlPointSType,
                controlPoint,
                (i == 1) ? " " : ", "
            ));
        }
        newHashOfSeed = currentHashOfSeed;
    }

    /**
     * @dev Generate a control point
     * @param currentHashOfSeed The seed to use for generating the control point
     * @param minX The minimum x value to use for the control point
     * @param minY The minimum y value to use for the control point
     * @param maxX The maximum x value to use for the control point
     * @param maxY The maximum y value to use for the control point
     */
    function generateControlPoint(bytes32 currentHashOfSeed, int minX, int maxX, int minY, int maxY) private pure returns (string memory controlPoint, bytes32 newHashOfSeed) {
        int x;
        (x, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, minX, maxX);
        int y;
        (y, currentHashOfSeed) = SeededRandomGenerator.randomInt(currentHashOfSeed, minY, maxY);

        controlPoint = string(abi.encodePacked(
            intToString(x),
            " ",
            intToString(y)
        ));
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
    function generateMatrixTransform(bytes32 currentHashOfSeed, int min, int max) private pure returns (string memory transformMatrix, bytes32 newHashOfSeed) {
        transformMatrix = "matrix(";
        int x;
        for (uint i = 0; i < 6; i++) {
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
    function generateTranslate(bytes32 currentHashOfSeed, int minX, int maxX, int minY, int maxY) private pure returns (string memory translate, bytes32 newHashOfSeed) {
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
    function generateAnimate(string memory attributeName, string memory values, int dur) private pure returns (string memory animate) {
        animate = string(abi.encodePacked(
            "<animate attributeName='", attributeName, "' values='", values, "' dur='", intToString(dur), "s' repeatCount='indefinite'/>"
        ));
    }

    /**
     * @dev Generate a animateTransform SVG element
     * @param input Input contaning AnimateTransformInputs type
     * Returns an animate SVG element as a string
     */
    function generateAnimateTransform(AnimateTransformInputs memory input) private pure returns (string memory animate) {
        animate = string(abi.encodePacked(
            "<animateTransform attributeName='", input.attributeName, "' attributeType='", input.attributeType, "' type='", input.typeOfTransform, "' values='", input.values, "' dur='", intToString(input.dur), "s' repeatCount='indefinite' additive='sum'/>"
        ));
    }

    /**
     * @dev Generate a element containing path along with its transformations and color
     * @param currentHashOfSeed The seed to use for generating the polygon group params
     * @param id ID of the parent polygon group element
     * @param color HSL color for the polygon group
     * @param layerIndex Index of the layer in the group
     */
    function generatePathGroup(bytes32 currentHashOfSeed, string memory id, HSL memory color, uint layerIndex) external pure returns (string memory pathGroup, bytes32 newHashOfSeed) {
        pathGroup = string(abi.encodePacked("<use xlink:href='#", id, "' transform='"));

        // Generate transform matrix
        string memory transformMatrix;
        (transformMatrix, currentHashOfSeed) = generateMatrixTransform(currentHashOfSeed, -100, 100);

        // Generate translate transformation
        string memory translate;
        if (layerIndex == 1) {
            translate = "translate(0,0)";
        } else if (layerIndex == 2) {
            (translate, currentHashOfSeed) = generateTranslate(currentHashOfSeed, 30, 40, 0, 10);
        } else if (layerIndex == 3) {
            (translate, currentHashOfSeed) = generateTranslate(currentHashOfSeed, 0, 10, 30, 40);
        } else {
            (translate, currentHashOfSeed) = generateTranslate(currentHashOfSeed, 10*int(layerIndex), 10*int(layerIndex) + 10, 10*int(layerIndex), 10*int(layerIndex) + 10);
        }

        pathGroup = string(abi.encodePacked(pathGroup, transformMatrix, " ", translate,"' fill='", HSLGenerator.toString(color), "' >"));

        // Generate animation
        string memory animate = generateAnimate("opacity", "1;0.3;1", 2 * int(layerIndex));

        pathGroup = string(abi.encodePacked(
            pathGroup,
            animate,
             "</use>"
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
    function generatePolygonGroup(bytes32 currentHashOfSeed, string memory id, HSL memory color, uint polygonIndex) external pure returns (string memory polygonGroup, bytes32 newHashOfSeed) {
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

    /**
    * @dev Utility functions for converting int to string
    * Returns string representation of int
    */
    function intToString(int x) private pure returns (string memory) {
        unchecked {
            return string(abi.encodePacked(x < 0 ? "-": "", Strings.toString(uint(x >=0 ? x : -x))));
        }
    }

    /**
    * @dev Utility functions that converts an int to a decimal with 2 significant digits
    * Returns string representation of decimal
    */
    function intToStringDecimalTwoSigFigs(int x) private pure returns (string memory decimal) {
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
}