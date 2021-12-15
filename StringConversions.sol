// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title StringConversions.sol - A utility solidity library for converting various things into a string format
 * @author Karsh Sinha <karsh@hey.com>
 */

library StringConversions {
    /**
     * @dev Converts a decimal number to a string.  The decimal number is represented by a int256, along with an additional param representing the number of decimal places.  e.g. (435, 2) -> "-4.35"; (-2843, 1) -> "-284.3"
     * @param _value The decimal number (represented by int256) to convert to a string
     * @param _decimalPlaces The number of decimal places (as uint256) to include in the string (max can only be 77)
     * @returns result The string representation of the decimal number
     */
    function decimalToString(int256 _value, uint256 _decimalPlaces) internal pure returns (string memory result) {
        require(_decimalPlaces <= 77, "Decimal places must be <= 77");

        int256 _wholePart = _value / (10 ** _decimalPlaces);
        int256 _fractionalPart = _value % (10 ** _decimalPlaces);

        // Convert the value to a string
        result = _value.toString();

        // If the decimal places is greater than 0, append the decimal point and the decimal places
        if (_decimalPlaces > 0) {
            result += ".";
            for (uint i = 0; i < _decimalPlaces; i++) {
                result += "0";
            }
        }

    }

    /**
     * @dev Convert an integer to a string
     * @param _value The int256 value to convert
     * @return result The string representation of the int256 value
     */
    function int256ToString(int256 _value) internal pure returns (string memory result) {
        uint256 _number = uint256((_value >= 0) ? _value : -_value);
        result = string(abi.encodePacked(
            (_value < 0) ? "-" : "",
            _toString(_number)
        ));
    }

    /**
     * @dev Convert an unsigned integer to a string
     * @param _value The uint256 value to convert
     * @return result The string representation of the uint256
     */
    function uint256ToString(uint256 _value) internal pure returns (string memory result) {
        result = _toString(_value);
    }

    /**
     * @dev Convert a uint256 to a string.  This function is a copy of the toString function in @openzeppelin/contracts/utils/Strings.sol
     * @param _value The uint256 to convert to string
     * @return result The string representation of the uint256
     */
    function _toString(uint256 _value) private pure returns (string memory result) {
        if (_value == 0) {
            return "0";
        }

        uint256 _temp = _value;
        uint256 _digits;
        while (_temp != 0) {
            _digits++;
            _temp /= 10;
        }
        bytes memory buffer = new bytes(_digits);
        while (_value != 0) {
            _digits -= 1;
            buffer[_digits] = bytes1(uint8(48 + uint256(_value % 10)));
            _value /= 10;
        }
        result = string(buffer);
    }
    
}