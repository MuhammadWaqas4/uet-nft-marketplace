// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title Repla Pro NFT, Sample.
 * @author Waqas.
 * @notice Repla Pro NFT.
 */
contract ReplaProNFT is ERC721{
    uint256 private _totalSupply;

    constructor() ERC721("Repla NFT Pro", "Repla") {
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
        _totalSupply += 1;
    }

    function mintBatch(address to, uint256[] memory tokenIds) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _mint(to, tokenIds[i]);
            _totalSupply += 1;
        }
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
        _totalSupply -= 1;
    }

    function burnBatch(uint256[] memory tokenIds) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _burn(tokenIds[i]);
            _totalSupply -= 1;
        }
    }
}