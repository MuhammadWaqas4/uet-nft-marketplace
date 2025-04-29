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
    // using SafeMath for uint256;

    using SafeERC20 for IERC20;

    uint256 public platformFee;
    address public platformFeeRecipient;

    IERC20 constant _ETH = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    event OfferAndMint(
        address _owner,
        address _bidder,
        uint256 _amount,
        string uri,
        uint256 mintIndex,
        IUET contractAddress
    );
    event AcceptBidAndMint(
        address _seller,
        address _bidder,
        uint256 _amount,
        uint256 mintIndex,
        IUET contractAddress
    );
    event BuyAndMint(
        address _seller,
        address _buyer,
        uint256 _amount,
        string uri,
        uint256 mintIndex,
        IUET contractAddress
    );
    event OfferAndTransfer(
        address _owner,
        address _bidder,
        uint256 _amount,
        uint256 tokenId,
        IUET contractAddress
    );
    event AcceptBidAndTransfer(
        address _seller,
        address _bidder,
        uint256 _amount,
        uint256 tokenId,
        uint256 deadline,
        IUET contractAddress
    );
    event BuyAndTransfer(
        address _seller,
        address _buyer,
        uint256 _amount,
        uint256 tokenId,
        IUET contractAddress
    );
    event WithdrawStoredInAccount(address recipient, uint256 amount);

    constructor(address _platformFeeRecipient) Ownable(msg.sender) {
        platformFee = 0;
        platformFeeRecipient = _platformFeeRecipient;
    }

    struct TradeDetails {
        address _seller;
        address _bidder;
        uint256 _amount;
        uint256 tokenId;
    }

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    enum BidType {
        OFFER,
        BID
    }

    function offerAndMint(
        TradeDetails memory values,
        string memory uri,
        Signature memory signSeller,
        Signature memory signBuyer,
        IUET contractAddress,
        uint256 offereTime,
        IERC20 tokenAddress,
        BidType bid
    ) public returns (uint256) {}

    /**
     * Mints UET
     */
    function offerAndMint(
        TradeDetails memory values,
        string memory uri,
        Signature memory signSeller,
        Signature memory signBuyer,
        IUET contractAddress,
        uint256 offereTime,
        IERC20 tokenAddress
    ) public returns (uint256) {
        require(
            tokenAddress.allowance(values._bidder, address(this)) >=
                values._amount,
            "Insufficient allowance: Bidder must approve tokens to the contract"
        );
        require(
            tokenAddress.balanceOf(values._bidder) >= values._amount,
            "Insufficient balance: Bidder does not have enough tokens"
        );

        IUET Nft = IUET(contractAddress);

        // require(deadline >= block.timestamp, "deadline passed");
        require(
            values._seller ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                _msgSender(),
                                values._amount,
                                offereTime,
                                values.tokenId,
                                tokenAddress
                            )
                        )
                    ),
                    signSeller.v,
                    signSeller.r,
                    signSeller.s
                ),
            "Invalid seller signature: Signature verification failed"
        );
        require(
            values._bidder ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                values._bidder,
                                values._amount,
                                offereTime,
                                values.tokenId,
                                tokenAddress
                            )
                        )
                    ),
                    signBuyer.v,
                    signBuyer.r,
                    signBuyer.s
                ),
            "Invalid bidder signature: Signature verification failed"
        );

        // uint256 _fee = platformFee.mul(values._amount).div(100);

        // weth.transferFrom(values._seller, platformFeeRecipient, _fee);
        // weth.transferFrom(values._bidder, values._seller, values._amount.sub(_fee));

        _processTokenPaymentsWithoutRotalty(
            values._bidder,
            values._seller,
            values._amount,
            tokenAddress
        );

        Nft.mintPro(values._bidder, uri, values.tokenId);
        emit OfferAndMint(
            values._seller,
            values._bidder,
            values._amount,
            uri,
            values.tokenId,
            contractAddress
        );

        return values.tokenId;
    }

    function acceptBidAndMint(
        TradeDetails memory values,
        string memory uri,
        Signature memory signSeller,
        Signature memory signBuyer,
        IUET contractAddress,
        uint256 deadline,
        IERC20 tokenAddress
    ) public returns (uint256) {
        require(
            tokenAddress.allowance(values._bidder, address(this)) >=
                values._amount,
            "allowance not provided"
        );
        require(
            tokenAddress.balanceOf(values._bidder) >= values._amount,
            "not enought balaance"
        );

        IUET Nft = IUET(contractAddress);

        require(
            deadline >= block.timestamp,
            "Bid expired: Deadline has passed"
        );
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

        _processTokenPaymentsWithoutRotalty(
            values._bidder,
            _msgSender(),
            values._amount,
            tokenAddress
        );

        Nft.mintPro(values._bidder, uri, values.tokenId);
        emit AcceptBidAndMint(
            values._seller,
            values._bidder,
            values._amount,
            values.tokenId,
            contractAddress
        );

        return values.tokenId;
    }

    function buyAndMint(
        TradeDetails memory values,
        string memory uri,
        Signature memory signSeller,
        Signature memory signBuyer,
        IUET contractAddress,
        uint256 offereTime,
        IERC20 tokenAddress
    ) public payable returns (uint256) {
        IUET Nft = IUET(contractAddress);

        // offer time is when the seller put on sale
        require(
            values._seller ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                values._seller,
                                values._amount,
                                offereTime
                            )
                        )
                    ),
                    signSeller.v,
                    signSeller.r,
                    signSeller.s
                ),
            "Seller signature is Invalid"
        );
        require(
            values._bidder ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                _msgSender(),
                                values._amount,
                                offereTime
                            )
                        )
                    ),
                    signBuyer.v,
                    signBuyer.r,
                    signBuyer.s
                ),
            "Buyer signature is Invalid"
        );
        if (tokenAddress == _ETH) {
            require(
                msg.value == values._amount,
                "Incorrect ETH amount: Sent value does not match required price"
            );
            _processEthPaymentsWithoutRoyalty(values._seller, values._amount);
        } else {
            _processTokenPaymentsWithoutRotalty(
                _msgSender(),
                values._seller,
                values._amount,
                tokenAddress
            );
        }

        Nft.mintPro(values._bidder, uri, values.tokenId);
        emit BuyAndMint(
            values._seller,
            values._bidder,
            values._amount,
            uri,
            values.tokenId,
            contractAddress
        );

        return values.tokenId;
    }

    function offerAndTransfer(
        TradeDetails memory values,
        Signature memory signSeller,
        Signature memory signBuyer,
        IUET contractAddress,
        address royaltyWallet,
        uint256 royalty,
        uint256 offereTime,
        IERC20 tokenAddress
    ) public returns (uint256) {
        require(
            tokenAddress.allowance(values._bidder, address(this)) >=
                values._amount,
            "Allowance not given"
        );
        require(
            tokenAddress.balanceOf(values._bidder) >= values._amount,
            "not enought balance"
        );

        IUET Nft = IUET(contractAddress);

        require(
            Nft.ownerOf(values.tokenId) == values._seller,
            "Invalid owner: Seller does not own the specified token"
        );
        require(
            Nft.isApprovedForAll(values._seller, address(this)),
            "Approval missing: Seller must approve contract to transfer NFT"
        );

        // require(deadline >= block.timestamp, "deadline passed");
        require(
            values._seller ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                _msgSender(),
                                values._amount,
                                offereTime,
                                values.tokenId,
                                tokenAddress
                            )
                        )
                    ),
                    signSeller.v,
                    signSeller.r,
                    signSeller.s
                ),
            "Owner signature is Invalid"
        );
        require(
            values._bidder ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                values._bidder,
                                values._amount,
                                offereTime,
                                values.tokenId,
                                tokenAddress
                            )
                        )
                    ),
                    signBuyer.v,
                    signBuyer.r,
                    signBuyer.s
                ),
            "Bidder signature is Invalid"
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
        emit OfferAndTransfer(
            values._seller,
            values._bidder,
            values._amount,
            values.tokenId,
            contractAddress
        );

        return values.tokenId;
    }

    function acceptBidAndTransfer(
        TradeDetails memory values,
        uint256 deadline,
        Signature memory signSeller,
        Signature memory signBuyer,
        IUET contractAddress,
        address royaltyWallet,
        uint256 royalty,
        IERC20 tokenAddress
    ) public returns (uint256) {
        require(
            tokenAddress.allowance(values._bidder, address(this)) >=
                values._amount,
            "Allowance not given"
        );
        require(
            tokenAddress.balanceOf(values._bidder) >= values._amount,
            "not enought balaance"
        );

        IUET Nft = IUET(contractAddress);

        require(
            Nft.ownerOf(values.tokenId) == _msgSender(),
            "seller is not the owner"
        );
        require(
            Nft.isApprovedForAll(values._seller, address(this)),
            "Allowance is not provided"
        );
        require(deadline >= block.timestamp, "deadline passed");
        require(
            values._seller ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                _msgSender(),
                                deadline,
                                values._amount,
                                values.tokenId,
                                tokenAddress
                            )
                        )
                    ),
                    signSeller.v,
                    signSeller.r,
                    signSeller.s
                ),
            "Seller signature is Invalid"
        );
        require(
            values._bidder ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                values._bidder,
                                deadline,
                                values._amount,
                                values.tokenId,
                                tokenAddress
                            )
                        )
                    ),
                    signBuyer.v,
                    signBuyer.r,
                    signBuyer.s
                ),
            "Buyer signature is Invalid"
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
        emit AcceptBidAndTransfer(
            values._seller,
            values._bidder,
            values._amount,
            values.tokenId,
            deadline,
            contractAddress
        );

        return values.tokenId;
    }

    function buyAndTransfer(
        TradeDetails memory values,
        Signature memory signSeller,
        Signature memory signBuyer,
        IUET contractAddress,
        address royaltyWallet,
        uint256 royalty,
        uint256 offereTime,
        IERC20 tokenAddress
    ) public payable returns (uint256) {
        IUET Nft = IUET(contractAddress);

        require(
            Nft.ownerOf(values.tokenId) == values._seller,
            "seller is not the owner"
        );
        require(
            Nft.isApprovedForAll(values._seller, address(this)),
            "Allowance is not provided"
        );

        // offer time will be like when the seller put on sale
        require(
            values._seller ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                values._seller,
                                values._amount,
                                offereTime
                            )
                        )
                    ),
                    signSeller.v,
                    signSeller.r,
                    signSeller.s
                ),
            "Seller signature is Invalid"
        );

        require(
            values._bidder ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                _msgSender(),
                                values._amount,
                                offereTime
                            )
                        )
                    ),
                    signBuyer.v,
                    signBuyer.r,
                    signBuyer.s
                ),
            "Buyer signature is Invalid"
        );
        if (tokenAddress == _ETH) {
            require(msg.value == values._amount, "Value sent is not Correct");
            _processEthPayments(
                values._seller,
                royaltyWallet,
                royalty,
                values._amount
            );
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
        emit BuyAndTransfer(
            values._seller,
            values._bidder,
            values._amount,
            values.tokenId,
            contractAddress
        );

        return values.tokenId;
    }

    function signVerification(
        address seller,
        address buyer,
        uint256 deadline,
        uint256 amount,
        Signature memory signSeller,
        Signature memory signBuyer,
        uint256 tokenId,
        IERC20 tokenAddress
    ) public view returns (bool) {
        require(
            seller ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                seller,
                                deadline,
                                amount,
                                tokenId,
                                tokenAddress
                            )
                        )
                    ),
                    signSeller.v,
                    signSeller.r,
                    signSeller.s
                ),
            "Seller signature is Invalid"
        );
        require(
            buyer ==
                ecrecover(
                    getSignedHash(
                        keccak256(
                            abi.encodePacked(
                                this,
                                buyer,
                                deadline,
                                amount,
                                tokenId,
                                tokenAddress
                            )
                        )
                    ),
                    signBuyer.v,
                    signBuyer.r,
                    signBuyer.s
                ),
            "Buyer signature is Invalid"
        );

        return true;
    }

    function getSignedHash(bytes32 _messageHash) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function withdrawStoredInAccount() public {
        require(
            msg.sender == owner(),
            "Can only be called by the contract owner or the project owner"
        );
        _sendValue(payable(msg.sender), address(this).balance); //transfers funds to ownerWallet
    }

    function setfeeWallet(address addres) public onlyOwner {
        platformFeeRecipient = addres;
    }

    function setPlatformfee(uint256 amount) public onlyOwner {
        require(amount <= 5, "Platoform fee too high: Must be 5% or less");
        platformFee = amount;
    }

    function _processTokenPaymentsWithoutRotalty(
        address _bidder,
        address _seller,
        uint256 amount,
        IERC20 tokenAddress
    ) internal {
        uint256 _fee = (platformFee * amount) / 100;
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
    ) internal {
        require(royaltyFee <= 10, "Royalty fee too high: Must be 10% or less");

        uint256 royalty = (royaltyFee * amount) / 100;
        uint256 _fee = platformFee * amount - royalty / 100;

        tokenAddress.safeTransferFrom(_bidder, platformFeeRecipient, _fee);
        tokenAddress.safeTransferFrom(_bidder, royaltyWallet, royalty);
        tokenAddress.safeTransferFrom(
            _bidder,
            _seller,
            amount - _fee - royalty
        );
    }

    function _processEthPayments(
        address _seller,
        address royaltyWallet,
        uint256 royaltyFee,
        uint256 amount
    ) internal {
        require(royaltyFee <= 10, "Royalty fee too high: Must be 10% or less");

        uint256 royalty = (royaltyFee * amount) / 100;
        uint256 _fee = platformFee * amount - royalty / 100;

        payable(royaltyWallet).transfer(royalty);
        payable(platformFeeRecipient).transfer(_fee);
        payable(_seller).transfer(amount - _fee - royalty);
    }

    function _processEthPaymentsWithoutRoyalty(
        address _seller,
        uint256 amount
    ) internal {
        uint256 _fee = (platformFee * amount) / 100;
        payable(platformFeeRecipient).transfer(_fee);
        payable(_seller).transfer(amount - _fee);
    }

    function _sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
        emit WithdrawStoredInAccount(recipient, amount);
    }
}
