// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "forge-std/Test.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IPAI3Node } from "contracts/interfaces/IPAI3Node.sol";

/**
 * @title TestStorage.
 * @author PAI3 Team.
 * @notice Test storage for PAI3 Node test.
 */
abstract contract TestStorage is Test {
    /* ========================== STATE VARIABLES ========================== */

    address public secondary;
    address public tertiary;

    uint256 public endRewardEquivalence;

    uint256 public totalSupply;

    address public owner;

    string public name;
    string public symbol;
    uint256 public cap;

    address public treasuryWallet;
    address public rewardWallet;

    uint256 public signerPrivateKey;
    address public signer;

    uint256 public secondarySignerPrivateKey;
    address public secondarySigner;

    string public baseURI;

    uint128[2] public situationalCaps;

    uint256[2] public saleBaseCosts;

    uint256[5] public phaseBaseCosts;

    IPAI3Node.Window[3] public windows;

    uint256[] public costSingleEth;
    uint256[] public costSingleUSDT;

    /* ========================== TYPES ========================== */

    enum Type {
        NODE,
        WHITELIST,
        FIRST,
        SECOND,
        THIRD,
        FOURTH,
        FIFTH
    }

    struct PriceData {
        uint256 priceDecimals;
        uint256 decimals;
        uint256 price;
    }

    struct MintSaleParams {
        IPAI3Node.Sale sale;
        uint8 saleIndex;
        uint256 quantity;
        uint256 deadline;
        uint256 privateKey;
        uint256 costSingle;
        uint256 cost;
        address caller;
        IERC20 token;
        IPAI3Node pai3Node;
        bytes4 errorSelector;
    }

    struct MintParams {
        uint256 quantity;
        uint256 costSingle;
        uint256 cost;
        address caller;
        IERC20 token;
        IPAI3Node pai3Node;
        bytes4 errorSelector;
    }

    struct ClaimParams {
        uint256 tokenId;
        uint256 deadline;
        uint256 privateKey;
        address caller;
        IPAI3Node pai3Node;
        bytes4 errorSelector;
    }

    /* ========================== CONSTRUCTOR ========================== */

    constructor() {
        secondary = address(0xAAAA);
        tertiary = address(0xBBBB);

        endRewardEquivalence = 0.000000000027744 * 1e18;

        totalSupply = vm.envUint("TOTAL_SUPPLY");

        owner = address(0xCCCC);

        name = vm.envString("NAME");
        symbol = vm.envString("SYMBOL");
        cap = vm.envUint("CAP");

        treasuryWallet = address(0xDDDD);
        rewardWallet = address(0xEEEE);

        signerPrivateKey = 100;
        signer = vm.addr(signerPrivateKey);

        secondarySignerPrivateKey = 200;
        secondarySigner = vm.addr(secondarySignerPrivateKey);

        baseURI = "ipfs://Q.../";

        // Situational caps.

        uint256[] memory tempSituationalCaps = vm.envUint(
            "SITUATIONAL_CAPS",
            "|"
        );

        for (uint256 i; i < tempSituationalCaps.length; ++i) {
            situationalCaps[i] = uint128(tempSituationalCaps[i]);
        }

        // Sale base costs.

        uint256[] memory temp = vm.envUint("SALE_BASE_COSTS", "|");

        for (uint256 i; i < temp.length; ++i) {
            saleBaseCosts[i] = temp[i];

            costSingleEth.push((temp[i] * 1e26) / (4000 * 1e8));
            costSingleUSDT.push((temp[i] * 1e14) / (1 * 1e8));
        }

        // Phase base costs.

        temp = vm.envUint("PHASE_BASE_COSTS", "|");

        for (uint256 i; i < temp.length; ++i) {
            phaseBaseCosts[i] = temp[i];

            costSingleEth.push((temp[i] * 1e26) / (4000 * 1e8));
            costSingleUSDT.push((temp[i] * 1e14) / (1 * 1e8));
        }

        // Windows.

        uint128 saleStartTimestamp = 0;
        uint128 saleEndTimestamp = saleStartTimestamp + 2 days;
        uint128 firstPhaseStartTimestamp = saleEndTimestamp + 1 days;
        uint128 firstPhaseEndTimestamp = firstPhaseStartTimestamp + 3 days;

        windows[uint8(Type.NODE)] = IPAI3Node.Window({
            startTimestamp: saleStartTimestamp,
            endTimestamp: saleEndTimestamp
        });
        windows[uint8(Type.WHITELIST)] = IPAI3Node.Window({
            startTimestamp: saleStartTimestamp,
            endTimestamp: saleEndTimestamp
        });
        windows[uint8(Type.FIRST)] = IPAI3Node.Window({
            startTimestamp: firstPhaseStartTimestamp,
            endTimestamp: firstPhaseEndTimestamp
        });

        vm.label(secondary, "secondary");
        vm.label(tertiary, "tertiary");
        vm.label(owner, "owner");
        vm.label(treasuryWallet, "treasuryWallet");
        vm.label(rewardWallet, "rewardWallet");
        vm.label(signer, "signer");
        vm.label(secondarySigner, "secondarySigner");
    }
}
