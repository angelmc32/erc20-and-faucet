// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.15;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Capped} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {ERC20PresetMinterPauser} from "../lib/openzeppelin-contracts/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract ERC20Token is ERC20Capped, ERC20PresetMinterPauser {
    address payable public owner;

    constructor(
        string memory name_,
        string memory symbol_,
        address owner_,
        uint256 maxSupply_,
        uint256 initialSupply_
    )
        ERC20PresetMinterPauser(name_, symbol_)
        ERC20Capped(maxSupply_ * (10**(decimals())))
    {
        owner = payable(owner_);
        // Mint "initialSupply" tokens to "owner" address
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals) -> 18 decimals by default
        _mint(owner, initialSupply_ * 10**uint256(decimals()));
    }

    function setMinterRole(address newMinterAddress_) public onlyOwner {
        _setupRole(MINTER_ROLE, newMinterAddress_);
    }

    function mint(address to, uint256 amount)
        public
        virtual
        override(ERC20PresetMinterPauser)
    {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "ERC20PresetMinterPauser: must have minter role to mint"
        );
        _mint(to, amount);
    }

    function _mint(address account, uint256 amount)
        internal
        virtual
        override(ERC20Capped, ERC20)
    {
        require(
            ERC20.totalSupply() + amount <= cap(),
            "ERC20Capped: cap exceeded"
        );
        super._mint(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20PresetMinterPauser) {
        super._beforeTokenTransfer(from, to, amount);
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "ERC20Token: Only the contract owner can call this function"
        );
        _;
    }
}
