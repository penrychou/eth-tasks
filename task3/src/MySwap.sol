// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract MySwap {
    using SafeERC20 for IERC20;

    IERC20 public immutable token0; // WETH
    IERC20 public immutable token1; // Other ERC20 token

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    event AddLiquidity(
        address indexed sender,
        uint256 amount0,
        uint256 amount1
    );
    event RemoveLiquidity(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }
        
    function addLiquidity(address to) external returns (uint256 liquidity) {
        (uint256 _reserve0, uint256 _reserve1) = getReserves();
        uint256 balance0 = token0.balanceOf(address(this));
        uint256 balance1 = token1.balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        if (totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1);
        } else {
            liquidity = Math.min(
                (amount0 * totalSupply) / _reserve0,
                (amount1 * totalSupply) / _reserve1
            );
        }

        require(liquidity > 0, "Insufficient liquidity minted");

        balanceOf[to] += liquidity;
        totalSupply += liquidity;

        _updateReserve(balance0, balance1);
        emit AddLiquidity(msg.sender, amount0, amount1);
    }

    function removeLiquidity(
        address to
    ) external returns (uint256 amount0, uint256 amount1) {
        uint256 liquidity = balanceOf[msg.sender];
        (uint256 _reserve0, uint256 _reserve1) = getReserves();

        amount0 = (liquidity * _reserve0) / totalSupply;
        amount1 = (liquidity * _reserve1) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "Insufficient liquidity burned");

        balanceOf[msg.sender] -= liquidity;
        totalSupply -= liquidity;

        token0.safeTransfer(to, amount0);
        token1.safeTransfer(to, amount1);

        _updateReserve(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
        emit RemoveLiquidity(msg.sender, amount0, amount1, to);
    }

    function swap(uint256 amount0Out, uint256 amount1Out, address to) external {
        require(amount0Out > 0 || amount1Out > 0, "Insufficient output amount");
        (uint256 _reserve0, uint256 _reserve1) = getReserves();
        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "Insufficient liquidity"
        );

        uint256 balance0 = token0.balanceOf(address(this)) - amount0Out;
        uint256 balance1 = token1.balanceOf(address(this)) - amount1Out;

        uint256 amount0In = balance0 > _reserve0 - amount0Out
            ? balance0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out
            ? balance1 - (_reserve1 - amount1Out)
            : 0;
        require(amount0In > 0 || amount1In > 0, "Insufficient input amount");

        uint256 balance0Adjusted = balance0 * 1000 - amount0In * 3;
        uint256 balance1Adjusted = balance1 * 1000 - amount1In * 3;
        require(
            balance0Adjusted * balance1Adjusted >=
                uint256(_reserve0) * _reserve1 * (1000 ** 2),
            "K"
        );

        _updateReserve(balance0, balance1);

        if (amount0Out > 0) token0.safeTransfer(to, amount0Out);
        if (amount1Out > 0) token1.safeTransfer(to, amount1Out);

        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function getReserves()
        public
        view
        returns (uint256 _reserve0, uint256 _reserve1)
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    function _updateReserve(uint256 balance0, uint256 balance1) private {
        reserve0 = balance0;
        reserve1 = balance1;
    }
}
