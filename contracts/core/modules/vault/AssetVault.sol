// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IAssetVault} from "../../../interfaces/IAssetVault.sol";
import { Errors } from "../../../libraries/Errors.sol";

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

/**
 * @title AssetVault
 * @author API3 Latam.
 *
 * The Asset Vault is a vault for the storage of ERC721 assets.
 * Designed for one-time use, like a piggy bank. Once withdrawals are enabled,
 * and the safe is broken, the vault can no longer be used.
 *
 * It starts in a deposit-only state. Assets cannot be withdrawn at this point. When
 * the owner is allow and actually calls `enableWithdraw()`, 
 * the state is set to a 'withdrawEnabled' state.
 * Withdraws cannot be disabled once enabled. This restriction protects the interactions
 * of the assets kept in the vault from unexpected withdrawal and frontrunning attacks.
 *
 * This contract is based from the arcadexyz repository `v2-contracts`.
 * You can found the original at the URL:
 * https://github.com/arcadexyz/v2-contracts/blob/main/contracts/vault/AssetVault.sol
 *
 * @dev AssetVault only supports arbitrary external calls by the current owner of the vault.
 */
contract AssetVault is IAssetVault, Initializable, ERC721Holder, ReentrancyGuard  {
    // ========== Storage ==========
    /**
     * @notice True if withdrawals are allowed out of this vault.
     * @dev Once set to true, it cannot be reverted back to false.
    */
    bool public override withdrawEnabled;

    // ========== Modifiers ==========
    /**
     * @dev For methods only callable with withdraws enabled
     * (all withdrawal operations).
     */
    modifier onlyWithdrawEnabled () {
        if (!withdrawEnabled) {
            revert Errors.VaultWithdrawsDisabled();
        }
        _;
    }

    /**
     * @dev For methods only callable with withdraws disabled
     * (call operations and enabling withdraws).
     */
    modifier onlyWithdrawDisabled() {
        if (withdrawEnabled) {
            revert Errors.VaultWithdrawsEnabled();
        }
        _;
    }

    // ========== Initializer/Constructor ==========
    /**
     * @dev Disables initializers, so contract can only be used trough proxies.
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract, used on proxy deployments. In practice,
     * always called by the VaultFactory contract.
     */
    function initialize ()
     external initializer {
        if (
            withdrawEnabled ||
            ownershipToken != address(0)
        ) {
            revert Errors.AlreadyInitialized();
        }
    }

    // ========== Core Functions ==========
    /**
     * @dev See { IAssetVault.enableWithdraw }.
     */
    function enableWithdraw ()
     external override onlyWithdrawDisabled {
        withdrawEnabled = true;
        emit WithdrawEnabled(msg.sender);
    }

    /**
     * @dev See { IAssetVault.withdrawERC721 }.
     */
    function withdrawERC721 (
        address token,
        uint256 tokenId,
        address to
    ) external override onlyWithdrawEnabled {
        IERC721(token).safeTransferFrom(
            address(this),
            to,
            tokenId
        );
        emit WithdrawERC721(
            msg.sender,
            token,
            to,
            tokenId
        );
    }
}