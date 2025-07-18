// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; //importo el ERC20
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; //importo la interfaz para el ERC20

contract TokenB is ERC20 {
    constructor() ERC20("TokenB", "TKB") {
        _mint(msg.sender, 1000 * 10**18); // genero 1000 tokenB con 18 decimales
    }
}
