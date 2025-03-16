// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IUET is IERC721 {
    // custom minting functionality with id and uri.
    function mintPro(
        address recipient,
        string memory uri,
        uint256 mintIndex
    ) external payable returns (uint256);
}
