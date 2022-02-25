// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DungeonsAndDragonsCharacter is ERC721, VRFConsumerBase, Ownable {
    using Strings for string;

    // Protect against reentrancy
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    // rinkeby: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
    address public VRFCoordinator;
    // rinkeby: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709a
    address public LinkToken;

    /// @dev This is a representation of a DnD character.
    struct Character {
        string name;
        uint256 dex;
        uint256 str;
        uint256 con;
        uint256 inte;
        uint256 wis;
        uint256 cha;
        uint256 exp;
    }

    Character[] public characters;

    mapping(bytes32 => string) requestToCharacterName;
    mapping(bytes32 => address) requestToSender;
    mapping(bytes32 => uint256) requestToTokenId;

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Rinkeby
     * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK token address:                0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */
    /// @dev Constructor for the DnD character contract.
    /// @param _VRFCoordinator The address of the VRF coordinator.
    /// @param _LinkToken The address of the LINK token.
    /// @param _keyHash The key hash for the VRF.
    constructor(
        address _VRFCoordinator,
        address _LinkToken,
        bytes32 _keyHash
    )
        public
        VRFConsumerBase(_VRFCoordinator, _LinkToken)
        ERC721("DungeonsAndDragonsCharacter", "DnD")
    {
        VRFCoordinator = _VRFCoordinator;
        LinkToken = _LinkToken;
        keyHash = _keyHash;
        fee = 0.1 * 10**18; // 0.1 LINK
    }

    /// @dev Request a DnD character.
    /// @param _name The name of the character.
    /// @return The token request ID of the character.
    function requestNewRandomCharacter(string memory _name)
        public
        returns (bytes32)
    {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK in contract"
        );
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestToCharacterName[requestId] = _name;
        requestToSender[requestId] = msg.sender;
        return requestId;
    }

    /// @dev Get the URI that a Dnd character can be found at.
    /// @param _tokenId The token ID of the character.
    /// @return The URI of the character's metadata.
    function getTokenURI(uint256 _tokenId) public view returns (string memory) {
        return tokenURI(_tokenId);
    }

    /// @dev Set the URI of a Dnd character.
    /// @param _tokenId The token ID of the character.
    /// @param _tokenURI The URI of the character's metadata.
    function setTokenURI(uint256 _tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _setTokenURI(_tokenId, _tokenURI);
    }

    /// @dev Callback hook for when the VRF successfully returns a random number.
    /// @dev This function should only be called by the VRF Coordinator.
    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        uint256 newId = characters.length;
        uint256 str = randomNumber % 20;
        uint256 dex = randomNumber % 20;
        uint256 con = randomNumber % 20;
        uint256 inte = randomNumber % 20;
        uint256 wis = randomNumber % 20;
        uint256 cha = randomNumber % 20;
        uint256 exp = 0;

        characters.push(
            Character(
                requestToCharacterName[requestId],
                dex,
                str,
                con,
                inte,
                wis,
                cha,
                exp
            )
        );

        _safeMint(requestToSender[requestId], newId);
    }

    /// @dev Get the level of a DnD Character.
    /// @param _tokenId The token ID of the character.
    /// @return The level of the character.
    function getLevel(uint256 _tokenId) public view returns (uint256) {
        return sqrt(characters[_tokenId].exp);
    }

    /// @dev Get the total number of DnD characters.
    /// @return The total number of DnD characters.
    function getNumberOfCharacters() public view returns (uint256) {
        return characters.length;
    }

    /// @dev Get an overview of a DnD character.
    /// @param _tokenId The token ID of the character.
    /// @return (name, total skill points, level, raw exp)
    function getCharacterOverview(uint256 _tokenId)
        public
        view
        returns (
            string memory,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            characters[_tokenId].name,
            characters[_tokenId].str +
                characters[_tokenId].dex +
                characters[_tokenId].con +
                characters[_tokenId].inte +
                characters[_tokenId].wis +
                characters[_tokenId].cha,
            getLevel(_tokenId),
            characters[_tokenId].exp
        );
    }

    /// @dev Get the raw stats of a DnD character.
    /// @param _tokenId The token ID of the character.
    /// @return (str, dex, con, inte, wis, cha, exp)
    function getCharacterStats(uint256 _tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            characters[_tokenId].str,
            characters[_tokenId].dex,
            characters[_tokenId].con,
            characters[_tokenId].inte,
            characters[_tokenId].wis,
            characters[_tokenId].cha,
            characters[_tokenId].exp
        );
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
