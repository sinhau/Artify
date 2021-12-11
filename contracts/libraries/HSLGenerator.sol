// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Generate HSL colors based on different color schemes
 * @author Utkarsh Sinha <sinha.karsh@gmail.com>
 */

import "../structs/HSL.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library HSLGenerator {
    /**
     * @dev Generate full pallette of HSL colors based on given color scheme and root hue, saturation, and lightness
     * Returns an array of HSL colors
     */
    function generateHSL(string memory colorScheme, uint rootHue, uint rootSaturation, uint rootLightness) public pure returns (HSL[3] memory HSLColors) {
        require(keccak256(abi.encodePacked(colorScheme)) == keccak256(abi.encodePacked("triadic")) || keccak256(abi.encodePacked(colorScheme)) == keccak256(abi.encodePacked("split_complimentary")), "Invalid color scheme.  Only triadic and split_complimentary are supported right now.");
        require(rootSaturation > 0 && rootSaturation <= 100, "Invalid saturation.  Must be between 1 and 100.");
        require(rootLightness > 0 && rootLightness <= 100, "Invalid lightness.  Must be between 1 and 100.");


        if (keccak256(abi.encodePacked(colorScheme)) == keccak256(abi.encodePacked("triadic"))) {
            HSL memory firstColor = HSL(rootHue % 360, rootSaturation, rootLightness);
            HSL memory secondColor = HSL((rootHue + 120) % 360, rootSaturation, rootLightness);
            HSL memory thirdColor = HSL((rootHue + 240) % 360, rootSaturation, rootLightness);

            HSLColors = [firstColor, secondColor, thirdColor];
        } else if (keccak256(abi.encodePacked(colorScheme)) == keccak256(abi.encodePacked("split_complimentary"))) {
            HSL memory firstColor = HSL(rootHue % 360, rootSaturation, rootLightness);
            HSL memory secondColor = HSL((rootHue + 150) % 360, rootSaturation, rootLightness);
            HSL memory thirdColor = HSL((rootHue + 210) % 360, rootSaturation, rootLightness);

            HSLColors = [firstColor, secondColor, thirdColor];
        }

    }

    /**
     * @dev Convert HSL color to string representation used in SVG XML
     * Returns a string representation of the HSL color
     */
    function toString(HSL memory HSLColor) internal pure returns (string memory HSLColorString) {
        HSLColorString = string(abi.encodePacked(
            "hsl(",
            Strings.toString(HSLColor.hue), ",",
            Strings.toString(HSLColor.saturation), "%,",
            Strings.toString(HSLColor.lightness), "%",
            ")"
        ));
    }
}