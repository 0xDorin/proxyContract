// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IDexRouter} from "../src/interfaces/IDexRouter.sol";
import {IBondingCurveRouter} from "../src/interfaces/IBondingCurveRouter.sol";

contract CurveTest is Test {

    address CURVE_ROUTER;
    address MEME_TOKEN;
    address trader;
    address DEX_ROUTER;
    address BONDING_CURVE_ROUTER;
    function setUp() public {

        CURVE_ROUTER = address(0x6d66C49CA4C71E6816b23a4CD44AbDE142493131);
        MEME_TOKEN = address(0x28dc3123f9CBBE5344B42b10583621c982c88F33);
        trader = address(0x9a95D53397C9435DB560AA677091462D10B0E566);
        DEX_ROUTER = address(0xB966bF7eE06E62bFAaFC77f6100a63aB514Dd934);
        BONDING_CURVE_ROUTER = address(0x12dA2e0c09B712b68623a1bB3F8C79D7189E6d44);
        // DEX_ROUTER="0xB966bF7eE06E62bFAaFC77f6100a63aB514Dd934"
        console.log("MEME_TOKEN", MEME_TOKEN);
        console.log("trader", trader);
        
    }

    function testDexRouter() public {

        uint256 amountIn1 = 14696921345891327759077730;
        uint256 amountIn2 = 446141974343665649568603268;
        uint256 amountIn3 = 55767746793000000000000000;
        uint256 eth_1 = 990000000000000000;

        uint256 balance =  IERC20(MEME_TOKEN).balanceOf(trader);
        console.log("balance", balance);
        
        uint256 amountOutMin = 0;
        address token = MEME_TOKEN;
        address to = trader;
        uint256 deadline = block.timestamp + 60;

        uint256 DexExpectedAmount = IDexRouter(DEX_ROUTER).getAmountOut(MEME_TOKEN, amountIn1, false);
        uint256 BondingCurveExpectedAmount = IBondingCurveRouter(BONDING_CURVE_ROUTER).getAmountOut(MEME_TOKEN, eth_1, false);

    // struct BuyParams {
    //     uint256 amountOutMin; // Minimum amount of tokens to receive
    //     address token; // Address of the token to buy
    //     address to; // Address to receive the tokens
    //     uint256 deadline; // Timestamp after which the transaction will revert
    // }

        IBondingCurveRouter.BuyParams memory params = IBondingCurveRouter.BuyParams({   
            amountOutMin: BondingCurveExpectedAmount,
            token: MEME_TOKEN,
            to: trader,
            deadline: block.timestamp + 60
        });

        vm.deal(trader, 10 ether);
        vm.prank(trader);
        IBondingCurveRouter(BONDING_CURVE_ROUTER).buy{value: eth_1}(params);
        // uint256 expectedAmount2 = IDexRouter(DEX_ROUTER).getAmountOut(MEME_TOKEN, amountIn2, false);
        // uint256 expectedAmount3 = IDexRouter(DEX_ROUTER).getAmountOut(MEME_TOKEN, amountIn3, false);
        // console.log("expectedAmount 50", expectedAmount3);
        console.log("DexExpectedAmount ", DexExpectedAmount);
        console.log("BondingCurveExpectedAmount ", BondingCurveExpectedAmount);
        // console.log("expectedAmount 100", expectedAmount2);
        

    }

    // function testSellSuccess() public {
     
    //     (
    //         uint256 realMonReserve,
    //         uint256 realTokenReserve,
    //         uint256 virtualMonReserve,
    //         uint256 virtualTokenReserve,
    //         uint256 k,
    //         uint256 targetTokenAmount,
    //         uint256 initVirtualMonReserve,
    //         uint256 initVirtualTokenReserve
    //     ) = curve.curves(MEME_TOKEN);

    //     console.log("realMonReserve", realMonReserve);
    //     console.log("realTokenReserve", realTokenReserve);
    //     console.log("virtualMonReserve", virtualMonReserve);
    //     console.log("virtualTokenReserve", virtualTokenReserve);
    //     console.log("k", k);
    //     console.log("targetTokenAmount", targetTokenAmount);
    //     console.log("initVirtualMonReserve", initVirtualMonReserve);
    //     console.log("initVirtualTokenReserve", initVirtualTokenReserve);

        

    //     uint256 amountIn = IERC20(MEME_TOKEN).balanceOf(trader);

    //     // 예상 mON 수량 계산 (토큰→MON)
    //     uint256 amountOut = BondingCurveLibrary.getAmountOut(amountIn, k, virtualTokenReserve, virtualMonReserve);
    //     // 실제 받을 MON (fee 제외)
    //     uint256 fee = curve.calculateFeeAmount(amountOut);
    //     uint256 realAmountOut = amountOut - fee;

    //     console.log("before trader.balance", trader.balance);
    //     console.log("IERC20(MEME_TOKEN).balanceOf(trader)", IERC20(MEME_TOKEN).balanceOf(trader));

    //     vm.startPrank(trader);
    //     IERC20(MEME_TOKEN).approve(CURVE_ROUTER, amountIn);
    //     IBondingCurveRouter.SellParams memory params = IBondingCurveRouter.SellParams({
    //         amountIn: amountIn,
    //         amountOutMin: realAmountOut,
    //         token: MEME_TOKEN,
    //         to: trader,
    //         deadline: block.timestamp + 60
    //     });
    //     BondingCurveRouter(CURVE_ROUTER).sell(params);
    //     vm.stopPrank();

    //     // Trader가 올바르게 MON을 수령했는지 검증
    //     // assertEq(trader.balance, realAmountOut, "Trader should receive native token");
    //     // assertEq(IERC20(MEME_TOKEN).balanceOf(trader), 0, "Token balance should be zero after sell");
    //     console.log("trader.balance", trader.balance);
    //     console.log("IERC20(MEME_TOKEN).balanceOf(trader)", IERC20(MEME_TOKEN).balanceOf(trader));
    // }
}