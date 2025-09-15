// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;


import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title UET Sample NFT.
 * @author UET Team.
 * @notice UET Marketplace.
 */
contract Pro is ERC721{
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
    }

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function mintBatch(address to, uint256[] memory tokenIds) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _mint(to, tokenIds[i]);
        }
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    function burnBatch(uint256[] memory tokenIds) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _burn(tokenIds[i]);
        }
    }
}

contract ProFactory {
    // Store all deployed Pro contracts
    address[] public allProContracts;

    // Event to track deployments
    event ProCreated(address indexed creator, address indexed newPro, string name, string symbol);

    function createPro(string memory name, string memory symbol) external returns (address) {
        Pro newPro = new Pro(name, symbol);
        allProContracts.push(address(newPro));

        emit ProCreated(msg.sender, address(newPro), name, symbol);
        return address(newPro);
    }

    function getAllProContracts() external view returns (address[] memory) {
        return allProContracts;
    }
}
