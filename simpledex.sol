// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleDEX {
    address public owner; // quien despliega el contracto 
    address public tokenA; // direccion del contrato token A
    address public tokenB; // direccion del contrato token B
    uint256 public supplyA; // disponibilidad del token A en el pool
    uint256 public supplyB; // disponibilidad del token B en el pool

    event LiquidityAdded(address indexed source, uint256 amountA, uint256 amountB); //avisa cuando se añade liquidez al pool
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut); // avisa de una transaccion
    event LiquidityRemoved(address indexed source, uint256 amountA, uint256 amountB); //avisa cuando se elimina liquidez del pool

    modifier onlyOwner(){
    //para evitar que personas ajenas al pool remuevan o agreguen liquidez
    require(msg.sender == owner, "not the owner");
     _;
    }

    constructor(address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        // inicializo con las direcciones de los contratos proveedores de liquidez
    }

    function addLiquidity(uint256 amountA, uint256 amountB) external {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA); //toma liquidez de token A
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB); //toma liquidez de token B

        supplyA += amountA; //modifica estas variables para el calculo del precio
        supplyB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "You can't trade 0 tokens"); // para evitar las transacciones de 0 tokens
        uint256 amountBOut = supplyB - (supplyB * supplyA) / (supplyA + amountAIn); // calculo de la cantidad B a pagar suponiendo producto constante

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountAIn); // toma el cobro de los token A
        IERC20(tokenB).transfer(msg.sender, amountBOut); // emite el pago en token B

        supplyA += amountAIn; // modifica el valor de los supply para la proxima transaccion
        supplyB -= amountBOut;

        emit TokensSwapped(msg.sender, tokenA, amountAIn, tokenB, amountBOut);
    }

    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "You can't trade 0 tokens");
        uint256 amountAOut = supplyA-(supplyA* supplyB) / (supplyB + amountBIn);

        IERC20(tokenB).transferFrom(msg.sender, address(this), amountBIn);
        IERC20(tokenA).transfer(msg.sender, amountAOut);

        supplyB += amountBIn;
        supplyA -= amountAOut;

        emit TokensSwapped(msg.sender, tokenB, amountBIn, tokenA, amountAOut);
    }

    function removeLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA <= supplyA, "excesive amount"); //para remover liquidez requiero que haya sufiecientes tokens
        require(amountB <= supplyB, "excesive amount");

        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        supplyA -= amountA;
        supplyB -= amountB;

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    function getPrice(address _token) external view returns (uint256) {
        // informa el precio marginal de los tokens. Lo que se va a cobrar excatamente depende del monto que venda el trader
        if (_token == tokenA) {
            return (supplyB * 1e18) / supplyA; // precio de un token A valuado en token B
        } else if (_token == tokenB) {
            return (supplyA * 1e18) / supplyB; // precio de un token B valuado en token A
        } else {
            revert("Invalid token address");
        }
    }
}