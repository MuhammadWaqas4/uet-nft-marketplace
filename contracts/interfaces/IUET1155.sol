// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IUET1155 is IERC1155 {

    // custom minting functionality with id and uri.
    function mintPro(
        address recipient,
        uint256 mintIndex,
        uint256 value,
        bytes memory data
    ) external payable returns (uint256);

}
