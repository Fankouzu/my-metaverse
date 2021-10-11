// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "./ERC3664/extensions/ERC3664Updatable.sol";

contract MyMetaVerse is ERC3664Updatable, ERC721Enumerable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    /// @dev tokenID
    Counters.Counter private _tokenIdTracker;
    /// @dev tokenURI themes address map
    EnumerableMap.UintToAddressMap private _uriThemes;
    /// @dev GAME ROLE bytes
    bytes32 public constant GAME_ROLE = keccak256("GAME_ROLE");
    /// @dev Game Metadata
    struct GameMetadata {
        string name;
        string description;
        address gameAddress;
        bool exist;
    }
    /// @dev gameId => gameMetadata
    mapping(uint256 => GameMetadata) private _gameMetadatas;
    /// @dev userAddress => bool, same address can only be claim once
    mapping(address => bool) private _claimed;
    /// @dev gameAddress => gameId
    mapping(address => uint256) private _gamesId;
    /// @dev tokenId => themeId
    mapping(uint256 => uint256) public myUriTheme;

    /**
     * @dev Emitted when new game are cerated.
     */
    event NewGame(
        address indexed operator,
        uint256 indexed attrId,
        string name,
        string symbol,
        address gameContract
    );

    constructor() ERC721("MyMetaVerse", "MMV") {
        _setupRole(ATTACH_ROLE, address(this));
        _setupRole(GAME_ROLE, _msgSender());
    }

    /* view function */

    /**
     * @dev return gameId exist
     */
    function gameExists(uint256 gameId) public view returns (bool) {
        return _gameMetadatas[gameId].exist;
    }

    /**
     * @dev return gameName
     */
    function getGameName(uint256 gameId) public view returns (string memory) {
        return _gameMetadatas[gameId].name;
    }

    /**
     * @dev return gameDescription
     */
    function getGameDescription(uint256 gameId)
        public
        view
        returns (string memory)
    {
        return _gameMetadatas[gameId].description;
    }

    /**
     * @dev return gameAddress
     */
    function getGameAddress(uint256 gameId) public view returns (address) {
        return _gameMetadatas[gameId].gameAddress;
    }

    /**
     * @dev return gameId
     */
    function getGameId(address gameAddress) public view returns (uint256) {
        return _gamesId[gameAddress];
    }

    /**
     * @dev return current tokenId
     */
    function currentTokenId() public view returns (uint256) {
        return _tokenIdTracker.current();
    }

    /**
     * @dev return tokenURI by uri theme contract, themeId default is 1
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        uint256 uriTheme = myUriTheme[tokenId] == 0 ? 1 : myUriTheme[tokenId];

        return
            _uriThemes.contains(1)
                ? IERC721Metadata(getUriTheme(uriTheme)).tokenURI(tokenId)
                : super.tokenURI(tokenId);
    }

    /**
     * @dev return UriTheme address by themeId
     */
    function getUriTheme(uint256 themeId) public view returns (address) {
        require(_uriThemes.contains(themeId), "themeId error");
        return _uriThemes.get(themeId);
    }

    /* public function */

    /**
     * @dev add a new uriTheme, only admin can call
     */
    function addUriTheme(uint256 themeId, address uri) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "MyMetaVerse: must have DEFAULT_ADMIN_ROLE role"
        );
        require(!_uriThemes.contains(themeId), "themeId error");
        _uriThemes.set(themeId, uri);
    }

    /**
     * @dev remove a uriTheme, only admin can call
     */
    function removeUriTheme(uint256 themeId) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "MyMetaVerse: must have DEFAULT_ADMIN_ROLE role"
        );
        require(_uriThemes.contains(themeId), "themeId error");
        _uriThemes.remove(themeId);
    }

    /**
     * @dev set a uriTheme by tokenId from token owner
     */
    function setMyUriTheme(uint256 tokenId, uint256 themeId) public {
        require(ownerOf(tokenId) == _msgSender(), "you don't have this token");
        require(_uriThemes.contains(themeId), "themeId error");
        myUriTheme[tokenId] = themeId;
    }

    /**
     * @dev claim a new token, The same address can only be claim once.
     */
    function claim() public nonReentrant {
        require(!_claimed[_msgSender()], "Claimed");
        _claimed[_msgSender()] = true;
        _tokenIdTracker.increment();
        _safeMint(_msgSender(), _tokenIdTracker.current());
    }

    /**
     * @dev claim a new token from game address
     */
    function gameClaim(address to) public nonReentrant {
        require(
            hasRole(GAME_ROLE, _msgSender()),
            "MyMetaVerse: must have game role to claim"
        );
        _tokenIdTracker.increment();
        _safeMint(to, _tokenIdTracker.current());
    }

    /**
     * @dev add a new game, only admin can call
     */
    function newGame(
        uint256 _gameId,
        string memory _name,
        string memory _description,
        address _gameAddress
    ) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "MyMetaVerse: must have DEFAULT_ADMIN_ROLE role"
        );
        require(!gameExists(_gameId), "MyMetaVerse: game already exists");

        address operator = _msgSender();

        GameMetadata memory data = GameMetadata(
            _name,
            _description,
            _gameAddress,
            true
        );
        _gameMetadatas[_gameId] = data;
        _gamesId[_gameAddress] = _gameId;
        _setupRole(GAME_ROLE, _gameAddress);

        emit NewGame(operator, _gameId, _name, _description, _gameAddress);
    }

    /**
     * @dev mint a new attr from game address
     */
    function gameMint(
        uint256 attrId,
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) public {
        require(
            hasRole(GAME_ROLE, _msgSender()),
            "MyMetaVerse: must have game role to mint"
        );
        attrId = getGameId(_msgSender()) * 10000 + attrId;
        _mint(attrId, _name, _symbol, _uri);
    }

    /**
     * @dev [Batched] version of {gameMint}.
     */
    function gameMintBatch(
        uint256[] memory attrIds,
        string[] memory names,
        string[] memory symbols,
        string[] memory uris
    ) public {
        require(
            hasRole(GAME_ROLE, _msgSender()),
            "MyMetaVerse: must have game role to mint"
        );
        uint256 gameId = getGameId(_msgSender());
        for (uint256 i = 0; i < attrIds.length; i++) {
            attrIds[i] = gameId * 10000 + attrIds[i];
        }
        _mintBatch(attrIds, names, symbols, uris);
    }

    /**
     * @dev attach attribute to tokenId from game address
     */
    function gameAttach(
        uint256 tokenId,
        uint256 attrId,
        uint256 amount,
        bytes memory text,
        bool isPrimary
    ) public {
        require(
            hasRole(GAME_ROLE, _msgSender()),
            "MyMetaVerse: must have game role to attach"
        );
        uint256 gameId = getGameId(_msgSender());
        attrId = gameId * 10000 + attrId;
        IERC3664(address(this)).attach(
            tokenId,
            attrId,
            amount,
            text,
            isPrimary
        );
    }

    /**
     * @dev [Batched] version of {gameAttach}.
     */
    function gameBatchAttach(
        uint256 tokenId,
        uint256[] memory attrIds,
        uint256[] memory amounts,
        bytes[] memory texts
    ) public {
        require(
            hasRole(GAME_ROLE, _msgSender()),
            "MyMetaVerse: must have game role to attach"
        );

        uint256 gameId = getGameId(_msgSender());
        for (uint256 i = 0; i < attrIds.length; i++) {
            attrIds[i] = gameId * 10000 + attrIds[i];
        }
        IERC3664(address(this)).batchAttach(tokenId, attrIds, amounts, texts);
    }
}
