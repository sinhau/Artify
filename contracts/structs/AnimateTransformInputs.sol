// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Struct representing input values for generating animate transform SVG elments 
 * @author Utkarsh Sinha <sinha.karsh@gmail.com>
 */

struct AnimateTransformInputs {
    string attributeName;
    string attributeType;
    string typeOfTransform;
    string values;
    int dur;
}