// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Struct representing art attributes 
 * @author Utkarsh Sinha <sinha.karsh@gmail.com>
 */

struct ArtAttributes {
    int numControlPoints;
    int numOfLayers;
    int colorScheme;
    int rootHue;
    int rootSaturation;
    int rootLightness;
}