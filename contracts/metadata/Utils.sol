// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Utils {
    function getTraitsAsJson(
        uint256 floor,
        uint256 apartment
    ) internal pure returns (string memory) {
        string memory result = string.concat(
            stringTrait("Floor", toString(floor)),
            ",",
            stringTrait("Apartment", toString(apartment))
        );

        return string.concat('"attributes":[', result, "]");
    }

    function stringTrait(
        string memory traitName,
        string memory traitValue
    ) internal pure returns (string memory) {
        return
            string.concat(
                '{"trait_type":"',
                traitName,
                '","value":"',
                traitValue,
                '"}'
            );
    }

    function toString(uint256 value) internal pure returns (string memory str) {
        /// @solidity memory-safe-assembly
        assembly {
            str := add(mload(0x40), 0x80)
            mstore(0x40, add(str, 0x20))
            mstore(str, 0)

            let end := str

            let w := not(0)
            for {
                let temp := value
            } 1 {

            } {
                str := add(str, w)
                mstore8(str, add(48, mod(temp, 10)))
                temp := div(temp, 10)
                if iszero(temp) {
                    break
                }
            }

            let length := sub(end, str)
            str := sub(str, 0x20)
            mstore(str, length)
        }
    }

    function toString(int256 value) internal pure returns (string memory str) {
        if (value >= 0) {
            return toString(uint256(value));
        }
        unchecked {
            str = toString(uint256(-value));
        }
        /// @solidity memory-safe-assembly
        assembly {
            let length := mload(str)
            mstore(str, 0x2d)
            str := sub(str, 1)
            mstore(str, add(length, 1))
        }
    }

    function encode(
        bytes memory data,
        bool fileSafe,
        bool noPadding
    ) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let dataLength := mload(data)

            if dataLength {
                let encodedLength := shl(2, div(add(dataLength, 2), 3))

                result := mload(0x40)

                mstore(0x1f, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef")
                mstore(
                    0x3f,
                    xor(
                        "ghijklmnopqrstuvwxyz0123456789-_",
                        mul(iszero(fileSafe), 0x0670)
                    )
                )

                let ptr := add(result, 0x20)
                let end := add(ptr, encodedLength)

                for {

                } 1 {

                } {
                    data := add(data, 3)
                    let input := mload(data)

                    mstore8(0, mload(and(shr(18, input), 0x3F)))
                    mstore8(1, mload(and(shr(12, input), 0x3F)))
                    mstore8(2, mload(and(shr(6, input), 0x3F)))
                    mstore8(3, mload(and(input, 0x3F)))
                    mstore(ptr, mload(0x00))

                    ptr := add(ptr, 4)
                    if iszero(lt(ptr, end)) {
                        break
                    }
                }
                mstore(0x40, add(end, 0x20))
                let o := div(2, mod(dataLength, 3))
                mstore(sub(ptr, o), shl(240, 0x3d3d))
                o := mul(iszero(iszero(noPadding)), o)
                mstore(sub(ptr, o), 0)
                mstore(result, sub(encodedLength, o))
            }
        }
    }

    function encode(
        bytes memory data
    ) internal pure returns (string memory result) {
        result = encode(data, false, false);
    }

    function encode(
        bytes memory data,
        bool fileSafe
    ) internal pure returns (string memory result) {
        result = encode(data, fileSafe, false);
    }
}
