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
     * @param colorScheme 1 represents triadic, 2 represents split_complimentary
     * Returns an array of HSL colors
     */
    function generateHSLPalette(int colorScheme, int rootHue, int rootSaturation, int rootLightness) internal pure returns (HSL[3] memory HSLColors) {
        require(colorScheme == 1 || colorScheme == 2, "Invalid color scheme.  Only triadic and split_complimentary are supported right now.");
        require(rootHue >= 0, "Invalid root hue.  Must be a positive number");
        require(rootSaturation > 0 && rootSaturation <= 100, "Invalid saturation.  Must be between 1 and 100.");
        require(rootLightness > 0 && rootLightness <= 100, "Invalid lightness.  Must be between 1 and 100.");


        if (colorScheme == 1) { // triadic
            HSL memory firstColor = HSL(uint(rootHue) % 360, uint(rootSaturation), uint(rootLightness));
            HSL memory secondColor = HSL((uint(rootHue) + 120) % 360, uint(rootSaturation), uint(rootLightness));
            HSL memory thirdColor = HSL((uint(rootHue) + 240) % 360, uint(rootSaturation), uint(rootLightness));

            HSLColors = [firstColor, secondColor, thirdColor];
        } else if (colorScheme == 2) { // split_complimentary
            HSL memory firstColor = HSL(uint(rootHue) % 360, uint(rootSaturation), uint(rootLightness));
            HSL memory secondColor = HSL((uint(rootHue) + 150) % 360, uint(rootSaturation), uint(rootLightness));
            HSL memory thirdColor = HSL((uint(rootHue) + 210) % 360, uint(rootSaturation), uint(rootLightness));

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