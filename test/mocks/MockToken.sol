// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockToken.
 * @author PAI3 Team.
 * @notice Mock ERC20 token.
 */
contract MockToken is ERC20 {
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_
    ) ERC20(name_, symbol_) {
        _decimals = decimals_;
        _mint(msg.sender, initialSupply_);
    }

    function mint(uint256 value) external {
        _mint(msg.sender, value);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}
