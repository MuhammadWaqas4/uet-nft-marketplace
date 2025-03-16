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
// import { IUET } from "@openzeppelin/contracts/token/ERC721/IUET.sol";
import { IUET } from "./interfaces/IUET.sol";

/**
 * @title UET.
 * @author UET Team.
 * @notice UET Marketplace.
 */
contract Marketplace is Ownable {

    using SafeERC20 for IERC20;
    using Address for address payable;
    using Strings for string;
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    /* ========================== STATE VARIABLES ========================== */

    uint256 public platformFee;
    address public platformFeeRecipient;

    IERC20 constant _ETH = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    struct TradeDetails{
        address _seller; // remove
        address _bidder;
        uint256 _amount;
        uint256 tokenId;
    }

    struct Signature{
         uint8 v;
         bytes32 r;
         bytes32 s;
    }
    
    enum BidType {
        OFFER,
        BID
    }

    /* ========================== EVENTS ========================== */

    event OfferAndTransfer(address _owner,
        address _bidder,
        uint256 _amount,
        uint256 tokenId,
        IUET contractAddress
    );

    event AcceptBidAndTransfer(address  _seller,
        address _bidder,
        uint256 _amount,
        uint256 tokenId,
        uint256 deadline,
        IUET contractAddress
    );

    event BuyAndTransfer(address _seller,
        address _buyer,
        uint256 _amount,
        uint256 tokenId,
        IUET contractAddress
    );

    event WithdrawStoredInAccount(address recipient, uint256 amount);

    event FeeWalletUpdated(address indexed oldWallet, address indexed newWallet);

    event PlatformFeeUpdated(uint256 oldFee, uint256 newFee);

    /* ========================== CONSTRUCTOR ========================== */

    constructor(address _platformFeeRecipient) Ownable(msg.sender) {
        platformFee = 0;
        platformFeeRecipient = _platformFeeRecipient;
    }
    
    /* ========================== FUNCTIONS ========================== */

    // allowance check
    // balanceOf check
    // v, r, s
    
    function offerAndTransfer(
        TradeDetails memory values,
        bytes memory signSeller,
        bytes memory signBuyer,
        IUET contractAddress,
        address royaltyWallet,
        uint256 royalty,
         uint256 deadline,
        IERC20 tokenAddress,
        BidType bid
    ) public returns (uint256) {
        if(bid == BidType.BID){
            if (deadline < block.timestamp) {
                revert();
            }
        }
        if (tokenAddress.allowance(values._bidder, address(this)) < values._amount) {
            revert();
        }
        if (tokenAddress.balanceOf(values._bidder) < values._amount) {
            revert();
        }

        IUET Nft = IUET(contractAddress);
        
        if (Nft.ownerOf(values.tokenId) != values._seller) {
            revert();
        }
        if (!(Nft.isApprovedForAll(values._seller, address(this)))) {
            revert();
        }

        signVerification(
            _msgSender(),
            values._bidder,
            deadline,
            values._amount,
            signSeller,
            signBuyer,
            values.tokenId,
            tokenAddress
        );

        _processTokenPayments(
            values._bidder,
            _msgSender(),
            royaltyWallet,
            royalty,
            values._amount,
            tokenAddress
        );

        Nft.safeTransferFrom(values._seller, values._bidder, values.tokenId);
        // emit OfferAndTransfer(values._seller, values._bidder, values._amount,values.tokenId, contractAddress);
        // emit AcceptBidAndTransfer(values._seller, values._bidder, values._amount,values.tokenId, deadline, contractAddress);

        return values.tokenId;
    }

    function buyAndTransfer(
        TradeDetails memory values,
        bytes memory signSeller,
        bytes memory signBuyer,
        IUET contractAddress,
        address royaltyWallet,
        uint256 royalty,
        uint256 offerTime,
        IERC20 tokenAddress
    ) public payable returns (uint256) {
        IUET Nft = IUET(contractAddress);
        
        if (Nft.ownerOf(values.tokenId) != values._seller) {
            revert();
        }
        if (!(Nft.isApprovedForAll(values._seller, address(this)))) {
            revert();
        }
        
        // offer time will be like when the seller put on sale
        bytes32 hashSeller = keccak256(
            abi.encodePacked(this, values._seller, values._amount, offerTime, values.tokenId)
        ).toEthSignedMessageHash();

        if (values._seller != hashSeller.recover(signSeller)) {
            revert();
        }

        bytes32 hashBuyer = keccak256(
            abi.encodePacked(this, _msgSender(), values._amount, offerTime, values.tokenId)
        ).toEthSignedMessageHash();

        if (_msgSender() != hashBuyer.recover(signBuyer)) {
            revert();
        }

        if (tokenAddress ==  _ETH) {
            if (msg.value == values._amount) {
                _processEthPayments(values._seller, royaltyWallet, royalty, values._amount);
            } else {
                revert();
            }
        } else {
            _processTokenPayments(
                _msgSender(),
                values._seller,
                 royaltyWallet,
                royalty,
                values._amount,
                tokenAddress
            );
        }

        Nft.safeTransferFrom(values._seller, values._bidder, values.tokenId);
        emit BuyAndTransfer(values._seller, values._bidder, values._amount, values.tokenId, contractAddress);

        return values.tokenId;
    }

    function signVerification(
        address seller,
        address buyer,
        uint256 deadline,
        uint256 amount,
        bytes memory signSeller,
        bytes memory signBuyer,
        uint256 tokenId,
        IERC20 tokenAddress
    ) public view returns (bool){

        bytes32 hashSeller = keccak256(
            abi.encodePacked(this, seller, deadline, amount, tokenId, tokenAddress)
        ).toEthSignedMessageHash();

        bytes32 hashBuyer = keccak256(
            abi.encodePacked(this,  buyer, deadline, amount, tokenId, tokenAddress)
        ).toEthSignedMessageHash();

        if (seller != hashSeller.recover(signSeller)) {
            revert();
        }

        if (buyer != hashBuyer.recover(signBuyer)) {
            revert();
        }
        return true;
    }

    function withdrawStoredInAccount() public onlyOwner{
        uint256 amount = address(this).balance;
        if (amount > 0) {
            payable(msg.sender).sendValue(amount);
        }
        emit WithdrawStoredInAccount(msg.sender, amount);
    }

    function setfeeWallet(address newAddress) public onlyOwner{
        if (newAddress == address(0)){
            revert();
        }

        emit FeeWalletUpdated(platformFeeRecipient, newAddress);
        platformFeeRecipient = newAddress;
    }
    
    function setPlatformfee(uint256 amount) public onlyOwner{
        if (amount > 5) {
            payable(msg.sender).sendValue(amount);
        }
        emit PlatformFeeUpdated(platformFee, amount);
        platformFee = amount;
    }

    function _processTokenPaymentsWithoutRotalty(
        address _bidder,
        address _seller,
        uint256 amount,
        IERC20 tokenAddress
    ) internal{
        uint256 _fee = platformFee * amount / 100;
        tokenAddress.safeTransferFrom(_bidder, platformFeeRecipient, _fee);
        tokenAddress.safeTransferFrom(_bidder, _seller, amount - _fee);
    }

    function _processTokenPayments(
        address _bidder,
        address _seller,
        address royaltyWallet,
        uint256 royaltyFee,
        uint256 amount,
        IERC20 tokenAddress
    )  internal{
        if (royaltyFee > 10) {
            payable(msg.sender).sendValue(amount);
        }

        uint256 royalty = royaltyFee * amount / 100;
        uint256 _fee = platformFee * amount - royalty / 100;
        
        tokenAddress.safeTransferFrom(_bidder, platformFeeRecipient, _fee);
        tokenAddress.safeTransferFrom(_bidder, royaltyWallet, royalty);
        tokenAddress.safeTransferFrom(_bidder, _seller, amount - _fee - royalty);
    }

    function _processEthPayments(
        address _seller,
        address royaltyWallet,
        uint256 royaltyFee,
        uint256 amount
    ) internal{
        if (royaltyFee > 10) {
            payable(msg.sender).sendValue(amount);
        }
        uint256 royalty = royaltyFee * amount / 100;
        uint256 _fee = platformFee * amount - royalty / 100;

        payable(royaltyWallet).transfer(royalty);
        payable(platformFeeRecipient).transfer(_fee);
        payable(_seller).transfer(amount - _fee - royalty);
    }

    function _processEthPaymentsWithoutRoyalty(address _seller, uint256 amount) internal{
        uint256 _fee = platformFee * amount / 100;
        payable(platformFeeRecipient).transfer(_fee);
        payable(_seller).transfer(amount - _fee);
    }
}
