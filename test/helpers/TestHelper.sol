// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "forge-std/Test.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import { _ETH } from "contracts/utils/Globals.sol";

import { TestStorage } from "./TestStorage.sol";

/**
 * @title TestHelper.
 * @author PAI3 Team.
 * @notice Test helper for PAI3 Node test.
 */
abstract contract TestHelper is TestStorage {
    using SafeERC20 for IERC20;
    using MessageHashUtils for bytes32;

    /* ========================== FUNCTIONS ========================== */

    function _mintSaleHelper(MintSaleParams memory params) internal {
        bytes memory signature = _signSaleHelper(
            params.saleIndex,
            params.quantity,
            params.deadline,
            params.privateKey,
            params.caller
        );

        if (params.token == _ETH) {
            if (params.errorSelector != 0x0) {
                vm.expectRevert(params.errorSelector);
            }

            params.pai3Node.mintSaleWithEth{ value: params.cost }(
                params.quantity,
                params.deadline,
                params.sale,
                signature
            );
        } else {
            params.token.forceApprove(address(params.pai3Node), params.cost);

            if (params.errorSelector != 0x0) {
                vm.expectRevert(params.errorSelector);
            }

            params.pai3Node.mintSale(
                params.token,
                params.quantity,
                params.deadline,
                params.sale,
                signature
            );
        }
    }

    function _mintHelper(MintParams memory params) internal {
        if (params.token == _ETH) {
            if (params.errorSelector != 0x0) {
                vm.expectRevert(params.errorSelector);
            }

            params.pai3Node.mintWithEth{ value: params.cost }(params.quantity);
        } else {
            params.token.forceApprove(address(params.pai3Node), params.cost);

            if (params.errorSelector != 0x0) {
                vm.expectRevert(params.errorSelector);
            }

            params.pai3Node.mint(params.token, params.quantity);
        }
    }

    function _claimHelper(ClaimParams memory params) internal {
        bytes memory signature = _signClaimHelper(
            params.tokenId,
            params.deadline,
            params.privateKey,
            params.caller
        );

        if (params.errorSelector != 0x0) {
            vm.expectRevert(params.errorSelector);
        }

        params.pai3Node.claim(params.tokenId, params.deadline, signature);
    }

    function _signSaleHelper(
        uint8 saleIndex,
        uint256 quantity,
        uint256 deadline,
        uint256 privateKey,
        address caller
    ) private pure returns (bytes memory) {
        bytes32 messageHash = keccak256(
            abi.encodePacked(caller, saleIndex, quantity, deadline)
        );

        bytes32 digest = messageHash.toEthSignedMessageHash();

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        bytes memory signature = abi.encodePacked(r, s, v);

        return signature;
    }

    function _signClaimHelper(
        uint256 tokenId,
        uint256 deadline,
        uint256 privateKey,
        address caller
    ) private pure returns (bytes memory) {
        bytes32 messageHash = keccak256(
            abi.encodePacked(caller, tokenId, deadline)
        );

        bytes32 digest = messageHash.toEthSignedMessageHash();

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        bytes memory signature = abi.encodePacked(r, s, v);

        return signature;
    }
}
