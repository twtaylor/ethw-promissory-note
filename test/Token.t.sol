// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ETHwPNToken.sol";
import "../src/WETH.sol";

contract CounterTest is Test {

    WETH9 weth;    
    wETHPow public _token;

    function setUp() public {
        weth = new WETH9();

        weth.deposit{value: 10 ether}();

       _token = new wETHPow(address(weth));
    }

    function testMint() public {
        
    }

    // function testSetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
