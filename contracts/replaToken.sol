// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Token Pro.
 * @author Waqas.
 * @notice Repla Pro ERC20 Token.
 */
contract ProToken is ERC20 {
    uint256 private _totalSupply;

    constructor() ERC20("Pro Token", "PRO") {}

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
        _totalSupply += amount;
    }

    function mintBatch(address[] memory recipients, uint256[] memory amounts) external {
        require(recipients.length == amounts.length, "Arrays length mismatch");
        for (uint256 i = 0; i < recipients.length; i++) {
            _mint(recipients[i], amounts[i]);
            _totalSupply += amounts[i];
        }
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        _totalSupply -= amount;
    }

    function burnFrom(address account, uint256 amount) external {
        uint256 currentAllowance = allowance(account, msg.sender);
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, msg.sender, currentAllowance - amount);
        _burn(account, amount);
        _totalSupply -= amount;
    }
}
