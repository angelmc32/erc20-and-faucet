// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface IERC20Token is IERC20 {
    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) external;
}
