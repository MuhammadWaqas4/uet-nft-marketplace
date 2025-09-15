// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";


/**
 * @title UET Sample NFT.
 * @author UET Team.
 * @notice UET Marketplace.
 */
contract ProNFT is ERC721{
    constructor() ERC721("Pro", "Pro") {
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