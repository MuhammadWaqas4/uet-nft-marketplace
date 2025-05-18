// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";


/**
 * @title UET Sample NFT.
 * @author UET Team.
 * @notice UET Marketplace.
 */
contract Pro is ERC721{
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