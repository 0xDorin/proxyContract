// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.12;

/**
 * @title IDexRouter
 * @dev Interface for the DexRouter contract which handles token swaps through Uniswap V3
 * @notice Defines functions and structures for swapping MON (native token) for tokens and vice versa
 */
interface IDexRouter {
    /**
     * @notice Thrown when an unauthorized address attempts a restricted action
     */
    error Unauthorized();

    /**
     * @notice Thrown when the input amount for a swap is invalid (zero or incorrect)
     */
    error InvalidAmountIn();

    /**
     * @notice Thrown when the output amount for a swap is invalid (zero or incorrect)
     */
    error InvalidAmountOut();

    /**
     * @notice Thrown when the provided input amount is insufficient for the desired output
     */
    error InsufficientInput();

    /**
     * @notice Thrown when the resulting output amount is less than the minimum required
     */
    error InsufficientOutput();

    /**
     * @notice Thrown when a transaction is submitted after the deadline
     */
    error ExpiredDeadLine();

    /**
     * @notice Thrown when the swap callback is called from an invalid address
     */
    error InvalidCallback();

    /**
     * @notice Structure for fee configuration
     * @param protocolFee Protocol fee rate in parts per million (e.g., 10000 = 1%)
     * @param dexFee Fee tier used for Uniswap V3 pools
     */
    struct FeeConfig {
        uint24 protocolFee;
        uint24 dexFee;
    }

    /**
     * @notice Parameters for buying tokens with MON
     * @param amountOutMin Minimum amount of tokens to receive
     * @param token Address of the token to buy
     * @param to Address to receive the purchased tokens
     * @param deadline Timestamp after which the transaction will revert
     */
    struct BuyParams {
        uint256 amountOutMin;
        address token;
        address to;
        uint256 deadline;
    }

    /**
     * @notice Parameters for buying exact amount of tokens with MON
     * @param amountInMax Maximum amount of MON to spend
     * @param amountOut Exact amount of tokens to buy
     * @param token Address of the token to buy
     * @param to Address to receive the purchased tokens
     * @param deadline Timestamp after which the transaction will revert
     */
    struct ExactOutBuyParams {
        uint256 amountInMax;
        uint256 amountOut;
        address token;
        address to;
        uint256 deadline;
    }

    /**
     * @notice Parameters for selling tokens for MON
     * @param amountIn Amount of tokens to sell
     * @param amountOutMin Minimum amount of MON to receive
     * @param token Address of the token to sell
     * @param to Address to receive the MON
     * @param deadline Timestamp after which the transaction will revert
     */
    struct SellParams {
        uint256 amountIn;
        uint256 amountOutMin;
        address token;
        address to;
        uint256 deadline;
    }

    /**
     * @notice Parameters for selling tokens for MON with permit
     * @param amountIn Amount of tokens to sell
     * @param amountOutMin Minimum amount of MON to receive
     * @param amountAllowance Amount for the permit
     * @param token Address of the token to sell
     * @param to Address to receive the MON
     * @param deadline Timestamp after which the transaction will revert
     * @param v Part of the signature for permit
     * @param r Part of the signature for permit
     * @param s Part of the signature for permit
     */
    struct SellPermitParams {
        uint256 amountIn;
        uint256 amountOutMin;
        uint256 amountAllowance;
        address token;
        address to;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /**
     * @notice Parameters for selling tokens for exact amount of MON
     * @param amountInMax Maximum amount of tokens to sell
     * @param amountOut Exact amount of MON to receive
     * @param token Address of the token to sell
     * @param to Address to receive the MON
     * @param deadline Timestamp after which the transaction will revert
     */
    struct ExactOutSellParams {
        uint256 amountInMax;
        uint256 amountOut;
        address token;
        address to;
        uint256 deadline;
    }

    /**
     * @notice Parameters for selling tokens for exact amount of MON with permit
     * @param amountInMax Maximum amount of tokens to sell
     * @param amountOut Exact amount of MON to receive
     * @param amountAllowance Amount for the permit
     * @param token Address of the token to sell
     * @param to Address to receive the MON
     * @param deadline Timestamp after which the transaction will revert
     * @param v Part of the signature for permit
     * @param r Part of the signature for permit
     * @param s Part of the signature for permit
     */
    struct ExactOutSellPermitParams {
        uint256 amountInMax;
        uint256 amountOut;
        uint256 amountAllowance;
        address token;
        address to;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /**
     * @notice Data structure for Uniswap V3 swap callbacks
     * @param token0 The first token in the pair
     * @param token1 The second token in the pair
     * @param fee The fee tier of the pool
     */
    struct SwapCallbackData {
        address token0;
        address token1;
        uint24 fee;
    }

    /**
     * @notice Emitted when tokens are bought using MON through the DEX router
     * @param sender Address that initiated the buy transaction
     * @param token Address of the token that was purchased
     * @param amountIn Amount of MON tokens paid
     * @param amountOut Amount of tokens received
     */
    event DexRouterBuy(address indexed sender, address indexed token, uint256 amountIn, uint256 amountOut);

    /**
     * @notice Emitted when tokens are sold for MON through the DEX router
     * @param sender Address that initiated the sell transaction
     * @param token Address of the token that was sold
     * @param amountIn Amount of tokens sold
     * @param amountOut Amount of MON tokens received
     */
    event DexRouterSell(address indexed sender, address indexed token, uint256 amountIn, uint256 amountOut);

    /**
     * @notice Swaps MON for tokens with minimum output amount
     * @param params Parameters including minimum output amount, token address, recipient and deadline
     * @return amountOut The actual amount of tokens received from the swap
     */
    function buy(BuyParams calldata params) external payable returns (uint256 amountOut);

    /**
     * @notice Swaps MON for exact amount of tokens, with maximum input limit
     * @param params Parameters including maximum input amount, exact output amount, token address,
     *              recipient and deadline
     * @return amountIn The actual amount of MON used for the swap
     */
    function exactOutBuy(ExactOutBuyParams calldata params) external payable returns (uint256 amountIn);

    /**
     * @notice Swaps tokens for MON with minimum output amount
     * @param params Parameters including input amount, minimum output amount, token address, recipient and deadline
     * @return amountOut The actual amount of MON received from the swap
     */
    function sell(SellParams calldata params) external returns (uint256 amountOut);

    /**
     * @notice Swaps tokens for MON with minimum output amount using permit
     * @param params Parameters including input amount, minimum output amount, token address, sender, recipient and deadline
     * @return amountOut The actual amount of MON received from the swap
     */
    function sellPermit(SellPermitParams calldata params) external returns (uint256 amountOut);

    /**
     * @notice Swaps tokens for exact amount of MON
     * @param params Parameters including maximum input amount, exact output amount, token address, recipient and deadline
     * @return amountIn The actual amount of tokens used for the swap
     */
    function exactOutSell(ExactOutSellParams calldata params) external returns (uint256 amountIn);

    /**
     * @notice Swaps tokens for exact amount of MON using permit
     * @param params Parameters including maximum input amount, exact output amount, token address, sender, recipient and deadline
     * @return amountIn The actual amount of tokens used for the swap
     */
    function exactOutSellPermit(ExactOutSellPermitParams calldata params) external returns (uint256 amountIn);

    /**
     * @notice Calculates the fee amount based on the protocol fee
     * @param amount Amount to calculate fee for
     * @return feeAmount Fee amount calculated
     */
    function calculateFeeAmount(uint256 amount) external view returns (uint256 feeAmount);

    /**
     * @notice Splits the amount into fee and remaining amount
     * @param _amount Amount to split
     * @param isBuy true if buying token with MON, false if selling token for MON
     * @return amount Remaining amount after fee
     * @return fee Fee amount
     */
    function splitAmountAndFee(uint256 _amount, bool isBuy) external view returns (uint256 amount, uint256 fee);

    /**
     * @notice Calculates the output amount for a given input
     * @param token Address of the token
     * @param amountIn Input amount (MON with fee for buy, TOKEN without fee for sell)
     * @param is_buy true if buying token with MON, false if selling token for MON
     * @return amountOut The actual output amount user will receive after fees
     */
    function getAmountOut(address token, uint256 amountIn, bool is_buy) external returns (uint256 amountOut);

    /**
     * @notice Calculates the required input amount including fees to get a desired output
     * @param token Address of the token
     * @param amountOut Desired output amount user wants to receive
     * @param is_buy true if buying token with MON, false if selling token for MON
     * @return amountIn Total input amount required including fees
     */
    function getAmountIn(address token, uint256 amountOut, bool is_buy) external returns (uint256 amountIn);
}
