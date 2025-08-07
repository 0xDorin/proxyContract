// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.12;

interface IBondingCurveRouter {
    // Custom errors
    /// @notice Thrown when a transaction is submitted after the deadline
    error DeadlineExpired();
    /// @notice Thrown when the provided MON amount is insufficient for the operation
    error InsufficientMon();
    /// @notice Thrown when the output amount is below the required minimum
    error InsufficientAmountOut();
    /// @notice Thrown when the input amount exceeds the maximum allowed
    error InsufficientAmountInMax();
    /// @notice Thrown when the input amount is too low for the operation
    error InsufficientAmountIn();
    /// @notice Thrown when the token allowance is invalid or insufficient
    error InvalidAllowance();

    // Token Creation

    struct TokenCreationParams {
        address creator; // Address of the token creator
        string name; // Name of the token
        string symbol; // Symbol of the token
        string tokenURI; // Token URI of the token
        uint256 amountOut; // Initial amount of tokens to mint
    }

    // Buy Operations
    struct BuyParams {
        uint256 amountOutMin; // Minimum amount of tokens to receive
        address token; // Address of the token to buy
        address to; // Address to receive the tokens
        uint256 deadline; // Timestamp after which the transaction will revert
    }

    struct ExactOutBuyParams {
        uint256 amountInMax; // Maximum amount of MON to spend
        uint256 amountOut; // Exact amount of tokens to receive
        address token; // Address of the token to buy
        address to; // Address to receive the tokens
        uint256 deadline; // Timestamp after which the transaction will revert
    }

    //===================Sell====================
    // Struct for sell parameters
    struct SellParams {
        uint256 amountIn; // Amount of tokens to sell
        uint256 amountOutMin; // Minimum amount of MON to receive
        address token; // Address of the token to sell
        address to; // Address to receive the MON
        uint256 deadline; // Timestamp after which the transaction will revert
    }

    // Struct for sell parameters with permit
    struct SellPermitParams {
        uint256 amountIn; // Amount of tokens to sell
        uint256 amountOutMin; // Minimum amount of MON to
        uint256 amountAllowance; // amount for the permit
        address token; // Address of the token to sell
        address to; // Address to receive the MON
        uint256 deadline; // Timestamp after which the transaction will revert
        uint8 v; // v part of the signature
        bytes32 r; // r part of the signature
        bytes32 s; // s part of the signature
    }

    // Struct for exact output sell parameters
    struct ExactOutSellParams {
        uint256 amountInMax; // Maximum amount of tokens to sell
        uint256 amountOut; // Exact amount of MON to receive
        address token; // Address of the token to sell
        address to; // Address to receive the MON
        uint256 deadline; // Timestamp after which the transaction will revert
    }

    // Struct for exact output sell parameters with permit
    struct ExactOutSellPermitParams {
        uint256 amountInMax; // Maximum amount of tokens to sell
        uint256 amountOut; // Exact amount of MON to receive
        uint256 amountAllowance; // amount for the permit
        address token; // Address of the token to sell
        address to; // Address to receive the MON
        uint256 deadline; // Timestamp after which the transaction will revert
        uint8 v; // v part of the signature
        bytes32 r; // r part of the signature
        bytes32 s; // s part of the signature
    }

    /**
     * @notice Creates a new token with a bonding curve
     * @param params TokenCreationParams containing token details and initial amount
     * @return token Address of the newly created token
     * @return pool Address of the newly created pool
     */
    function create(TokenCreationParams calldata params) external payable returns (address token, address pool);

    /**
     * @notice Buy tokens with MON (input amount is determined by msg.value)
     * @param params BuyParams containing minimum output and recipient details
     */
    function buy(BuyParams calldata params) external payable;

    /**
     * @notice Buy an exact amount of tokens with MON (capped by msg.value)
     * @param params ExactOutBuyParams containing exact output amount and max input
     */
    function exactOutBuy(ExactOutBuyParams calldata params) external payable;

    /**
     * @notice Sell tokens for MON
     * @param params SellParams containing input amount and minimum output
     */
    function sell(SellParams calldata params) external;

    /**
     * @notice Sell tokens for MON using permit (no pre-approval needed)
     * @param params SellPermitParams containing input amount, min output, and permit signature
     */
    function sellPermit(SellPermitParams calldata params) external;

    /**
     * @notice Sell tokens to receive an exact amount of MON
     * @param params ExactOutSellParams containing max input and exact output amount
     */
    function exactOutSell(ExactOutSellParams calldata params) external;

    /**
     * @notice Sell tokens to receive an exact amount of MON using permit
     * @param params ExactOutSellPermitParams containing max input, exact output, and permit signature
     */
    function exactOutSellPermit(ExactOutSellPermitParams calldata params) external;

    /**
     * @notice Returns the address of the wrapped MON token
     * @return Address of the wrapped MON token
     */
    function wMon() external view returns (address);

    /**
     * @notice Returns the address of the bonding curve contract
     * @return Address of the bonding curve contract
     */
    function curve() external view returns (address);

    /**
     * @notice Calculates the output amount for a given input
     * @param token Address of the token
     * @param amountIn Input amount (MON with fee for buy, TOKEN without fee for sell)
     * @param is_buy true if buy, false if sell
     * @return amountOut The actual output amount user will receive after fees
     */
    function getAmountOut(address token, uint256 amountIn, bool is_buy) external view returns (uint256 amountOut);

    /**
     * @notice Calculates the required input amount including fees to get a desired output
     * @param token Address of the token
     * @param amountOut Desired output amount user wants to receive
     * @param is_buy true if buy, false if sell
     * @return amountIn Total input amount required including fees
     */
    function getAmountIn(address token, uint256 amountOut, bool is_buy) external view returns (uint256 amountIn);

    /**
     * @notice Calculates the available tokens for purchase
     * @param token Address of the token
     * @return availableBuyToken The amount of tokens available for purchase
     * @return requiredMonAmount The amount of Mon available for purchase Token
     */
    function availableBuyTokens(address token)
        external
        view
        returns (uint256 availableBuyToken, uint256 requiredMonAmount);
}
