// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ILoot {
    function getWeapon(uint256 tokenId) external view returns (string memory);

    function getChest(uint256 tokenId) external view returns (string memory);

    function getHead(uint256 tokenId) external view returns (string memory);

    function getWaist(uint256 tokenId) external view returns (string memory);

    function getFoot(uint256 tokenId) external view returns (string memory);

    function getHand(uint256 tokenId) external view returns (string memory);

    function getNeck(uint256 tokenId) external view returns (string memory);

    function getRing(uint256 tokenId) external view returns (string memory);
}

interface IERC3664Generic {
    function gameMintBatch(
        uint256[] memory attrIds,
        string[] memory names,
        string[] memory symbols,
        string[] memory uris
    ) external;

    function gameBatchAttach(
        uint256 tokenId,
        uint256[] memory attrIds,
        uint256[] memory amounts,
        bytes[] memory texts
    ) external;

    function gameClaim(address to) external;

    function currentTokenId() external view returns (uint256);
}

contract SyntheticLoot is Context {
    address public loot;
    address public myMetaVerse;
    uint256[] public defaultAmount = [1, 1, 1, 1, 1, 1, 1, 1];
    uint256[] public attrIds = [1, 2, 3, 4, 5, 6, 7, 8];
    string[] public names = [
        "weapons",
        "chestArmor",
        "headArmor",
        "waistArmor",
        "footArmor",
        "handArmor",
        "necklaces",
        "rings"
    ];

    function init(address _loot, address _myMetaVerse) public {
        loot = _loot;
        myMetaVerse = _myMetaVerse;
        IERC3664Generic(_myMetaVerse).gameMintBatch(
            attrIds,
            names,
            names,
            new string[](8)
        );
    }

    function stake(uint256 tokenId, uint256 lootTokenId) public {
        IERC721(loot).transferFrom(_msgSender(), address(this), lootTokenId);
        synthetic(tokenId, lootTokenId);
    }

    function claimAndStake(uint256 lootTokenId) public {
        IERC3664Generic(myMetaVerse).gameClaim(_msgSender());
        uint256 tokenId = IERC3664Generic(myMetaVerse).currentTokenId();
        stake(tokenId, lootTokenId);
    }

    function synthetic(uint256 tokenId, uint256 lootTokenId) public {
        require(
            IERC721(loot).ownerOf(lootTokenId) == address(this),
            "I don't have this token"
        );
        require(
            IERC721(myMetaVerse).ownerOf(tokenId) == _msgSender(),
            "you don't have this token"
        );
        bytes[] memory texts = new bytes[](8);
        texts[0] = bytes(ILoot(loot).getWeapon(lootTokenId));
        texts[1] = bytes(ILoot(loot).getChest(lootTokenId));
        texts[2] = bytes(ILoot(loot).getHead(lootTokenId));
        texts[3] = bytes(ILoot(loot).getWaist(lootTokenId));
        texts[4] = bytes(ILoot(loot).getFoot(lootTokenId));
        texts[5] = bytes(ILoot(loot).getHand(lootTokenId));
        texts[6] = bytes(ILoot(loot).getNeck(lootTokenId));
        texts[7] = bytes(ILoot(loot).getRing(lootTokenId));
        IERC3664Generic(myMetaVerse).gameBatchAttach(
            tokenId,
            attrIds,
            defaultAmount,
            texts
        );
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        from;
        tokenId;
        data;
        return this.onERC721Received.selector;
    }
}
