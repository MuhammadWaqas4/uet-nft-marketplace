
// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/**
 * @title UET.
 * @author UET Team.
 * @notice UET Marketplace.
 */
contract Pro is ERC1155{
    constructor() ERC1155("Pro") {
    }

    function mintPro(address to, uint256 tokenId, uint256 value, bytes memory data) external {
        _mint(to, tokenId, value, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) external {
            _mintBatch(to, ids, values, data);
    }

    function burn(address from, uint256 id, uint256 value) external {
        _burn(from, id, value);
    }

    function burnBatch(address from, uint256[] memory ids, uint256[] memory values) external {
            _burnBatch(from, ids, values);
    }
}
