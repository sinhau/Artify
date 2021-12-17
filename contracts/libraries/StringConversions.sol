// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title StringConversions.sol - A utility solidity library for converting various things into a string format
 * @author Karsh Sinha <karsh@hey.com>
 */

library StringConversions {
    /**
     * @dev Converts a decimal number to a string.  The decimal number is represented by a int256 and always assuming two decimal places  e.g. 435->"4.35"; -2843->"-28.43"
     * @param _value The decimal number (represented by int256) to convert to a string
     * @return result The string representation of the decimal number
     */
    function decimalTwoSigFigsToStrings(int256 _value) external pure returns (string memory result) {
        int256 whole = _value / 100;
            
        int256 fractionInt = _value % 100;
        uint256 fraction = uint256(fractionInt >=0 ? fractionInt : -fractionInt);
        string memory fractionStr;
        if (fraction < 10) {
            fractionStr = string(abi.encodePacked("0", _toString(fraction)));
        } else {
            fractionStr = _toString(fraction);
        }

        result = string(abi.encodePacked(
            (_value >= -99 && _value < 0) ? "-": "",
            int256ToString(whole),
            ".",
            fractionStr
        ));
    }

    /**
     * @dev Converts a wallet address to its string representation
     * @param _address The wallet address to convert to a string
     * @return result The string representation of the wallet address
     */
    function addressToString(address _address) public pure returns (string memory result) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(_address)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = _char(hi);
            s[2*i+1] = _char(lo);            
        }
        result = string(s);

        result = string(abi.encodePacked("0x", result));
    }


    /**
     * @dev Convert an integer to a string
     * @param _value The int256 value to convert
     * @return result The string representation of the int256 value
     */
    function int256ToString(int256 _value) public pure returns (string memory result) {
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
    function uint256ToString(uint256 _value) external pure returns (string memory result) {
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

    function _char(bytes1 _b) private pure returns (bytes1 c) {
        if (uint8(_b) < 10) return bytes1(uint8(_b) + 0x30);
        else return bytes1(uint8(_b) + 0x57);
    }
    
}