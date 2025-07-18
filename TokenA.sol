// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; //importo el ERC20
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; //importo la interfaz para el ERC20

contract TokenA is ERC20 {
    constructor() ERC20("TokenA", "TKA") {
        _mint(msg.sender, 500 * 10**18); // genero 500 tokenA con 18 decimales
    }
}