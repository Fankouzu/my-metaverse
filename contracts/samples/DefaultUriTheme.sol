// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";

interface IERC3664 {
    function textOf(uint256 tokenId, uint256 attrId)
        external
        view
        returns (bytes memory);
}

contract DefaultUriTheme {
    address public immutable myMetaVerse;

    constructor(address _myMetaVerse) {
        myMetaVerse = _myMetaVerse;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        string[17] memory parts;
        parts[
            0
        ] = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width='100%' height='100%' fill='black' /><text x='10' y='20' class='base'>";

        parts[1] = string(IERC3664(myMetaVerse).textOf(tokenId, 10001));

        parts[2] = "</text><text x='10' y='40' class='base'>";

        parts[3] = string(IERC3664(myMetaVerse).textOf(tokenId, 10002));

        parts[4] = "</text><text x='10' y='60' class='base'>";

        parts[5] = string(IERC3664(myMetaVerse).textOf(tokenId, 10003));

        parts[6] = "</text><text x='10' y='80' class='base'>";

        parts[7] = string(IERC3664(myMetaVerse).textOf(tokenId, 10004));

        parts[8] = "</text><text x='10' y='100' class='base'>";

        parts[9] = string(IERC3664(myMetaVerse).textOf(tokenId, 10005));

        parts[10] = "</text><text x='10' y='120' class='base'>";

        parts[11] = string(IERC3664(myMetaVerse).textOf(tokenId, 10006));

        parts[12] = "</text><text x='10' y='140' class='base'>";

        parts[13] = string(IERC3664(myMetaVerse).textOf(tokenId, 10007));

        parts[14] = "</text><text x='10' y='160' class='base'>";

        parts[15] = string(IERC3664(myMetaVerse).textOf(tokenId, 10008));

        parts[16] = "</text></svg>";

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );
        output = string(
            abi.encodePacked(
                output,
                parts[9],
                parts[10],
                parts[11],
                parts[12],
                parts[13],
                parts[14],
                parts[15],
                parts[16]
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        "{'name': 'Bag #",
                        Strings.toString(tokenId),
                        "', 'description': 'Loot is randomized adventurer gear generated and stored on chain. Stats, images, and other functionality are intentionally omitted for others to interpret. Feel free to use Loot in any way you want.', 'image': 'data:image/svg+xml;base64,",
                        Base64.encode(bytes(output)),
                        "','attributes': [",
                        abi.encodePacked(
                            "{'trait_type': 'Weapon', 'value': '",
                            parts[1],
                            "'},",
                            "{'trait_type': 'Chest', 'value': '",
                            parts[3],
                            "'},",
                            "{'trait_type': 'Head', 'value': '",
                            parts[5],
                            "'},"
                        ),
                        abi.encodePacked(
                            "{'trait_type': 'Waist', 'value': '",
                            parts[7],
                            "'},",
                            "{'trait_type': 'Foot', 'value': '",
                            parts[9],
                            "'},",
                            "{'trait_type': 'Hand', 'value': '",
                            parts[11],
                            "'},"
                        ),
                        abi.encodePacked(
                            "{'trait_type': 'Neck', 'value': '",
                            parts[13],
                            "'},",
                            "{'trait_type': 'Ring', 'value': '",
                            parts[15],
                            "'}"
                        ),
                        "]}"
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant _TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = _TABLE;

        //solhint-disable-next-line
        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
