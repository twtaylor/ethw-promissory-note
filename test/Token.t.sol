// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/ETHwPNToken.sol";
import "../src/WETH.sol";

contract CounterTest is Test {

    WETH9 public _weth;    
    wETHPow public _token;

    address alice = address(0x10000000);
    address owner = address(0x20000000);

    function setUp() public {
        _weth = new WETH9();
        vm.prank(owner);
       _token = new wETHPow(address(_weth));

        vm.chainId(1);
    }

    // mint eth

    function testMintEthPreFork() public {
        vm.chainId(1);
        
        _token.mintWithEth{value: 1 ether}();

        DSTest.assertTrue(_token.balanceOf(address(this)) == 1 ether);
        DSTest.assertTrue(_weth.balanceOf(address(_token)) == 1 ether);
        DSTest.assertTrue(_token.originalOwnerNotes(address(this)) == 1 ether);
    }

    function testDoubleMintEthPreFork() public {
        vm.chainId(1);
        
        _token.mintWithEth{value: 1 ether}();

        _token.mintWithEth{value: 0.5 ether}();

        DSTest.assertTrue(_token.balanceOf(address(this)) == 1.5 ether);
        DSTest.assertTrue(_weth.balanceOf(address(_token)) == 1.5 ether);
    }

    function testFailEthMintPreFork() public {
        vm.chainId(1);
        vm.difficulty(18446744073709551618);

        vm.expectRevert();
        _token.mintWithEth{value: 1 ether}();
    }

    function testFailEthMintEthwChain() public {
        vm.chainId(10001);
        vm.difficulty(129382183);

        vm.expectRevert();
        
        _token.mintWithEth{value: 1 ether}();
    }

    // mint weth

    function testMintWethPreFork() public {
        vm.chainId(1);
        
        _weth.deposit{value: 1 ether}();
        _weth.approve(address(_token), 1 ether);

        _token.mint(1 ether);

        DSTest.assertTrue(_weth.balanceOf(address(_token)) == 1 ether);
        DSTest.assertTrue(_token.balanceOf(address(this)) == 1 ether);
        DSTest.assertTrue(_token.originalOwnerNotes(address(this)) == 1 ether);
    }

    // pre-fork burns

    function testPreForkBurnPreFork() public {
        vm.chainId(1);

        _token.mintWithEth{value: 1 ether}();

        DSTest.assertTrue(_token.balanceOf(address(this)) == 1 ether);
        DSTest.assertTrue(_weth.balanceOf(address(_token)) == 1 ether);
        DSTest.assertTrue(_weth.balanceOf(address(alice)) == 0);

        _token.burnPreForkOnEth(alice, 1 ether);

        DSTest.assertTrue(_weth.balanceOf(address(alice)) == 1 ether);
    }

    function testFailPreForkBurnPostForkEthWChain() public {
        vm.chainId(1);

        _token.mintWithEth{value: 1 ether}();

        vm.chainId(10001);

        _token.burnPreForkOnEth(alice, 1 ether);

         vm.expectRevert(bytes("NOT_ETH_PREFORK"));
    }

    function testFailPreForkBurn() public {
        vm.chainId(1);

        _token.mintWithEth{value: 1 ether}();

        vm.chainId(10001);

        _token.burnPreForkOnEth(alice, 1 ether);

         vm.expectRevert(bytes("NOT_ETH_PREFORK"));
    }

    // post fork chainid: 1 retrievals

    function testBurnPostForkOnEth() public {
        vm.chainId(1);

        _token.mintWithEth{value: 1 ether}();

        vm.difficulty(18446744073709551618);

        _token.burnPostForkOnEth(alice, 1 ether);

        DSTest.assertTrue(_weth.balanceOf(address(alice)) == 1 ether);
        DSTest.assertTrue(_weth.balanceOf(address(_token)) == 0);
        DSTest.assertTrue(_token.originalOwnerNotes(address(this)) == 0);
    }

    function testFailBurnPostForkOnEthDoubleBurn() public {
        vm.chainId(1);

        _token.mintWithEth{value: 1 ether}();

        vm.difficulty(18446744073709551618);

        _token.burnPostForkOnEth(alice, 2 ether);

        vm.expectRevert(bytes("NO_BAL"));
    }

    function testFailBurnPostForkOnEthWrongChain() public {
        vm.chainId(1);

        _token.mintWithEth{value: 1 ether}();

        vm.chainId(10001);

        _token.burnPostForkOnEth(alice, 2 ether);

        vm.expectRevert(bytes("NOT_ETH_PREFORK"));
    }

    function testFailBurnPostForkOnEthNoOriginalBal() public {
        vm.chainId(1);

        _token.mintWithEth{value: 1 ether}();

        _token.transfer(alice, 1 ether);
        
        vm.startPrank(alice);

        _token.burnPostForkOnEth(owner, 1 ether);
        vm.expectRevert(bytes("NO_BAL"));

        vm.stopPrank();
    }

    function testFailBurnPostForkOnEthNoTok() public {
        vm.chainId(1);

        _token.mintWithEth{value: 1 ether}();

        _token.transfer(alice, 1 ether);
        
        _token.burnPostForkOnEth(owner, 1 ether);
        vm.expectRevert(bytes("ERC20: burn amount exceeds balance"));
    }

    // post fork chainid: 10001 retrievals
   
     function testBurnPostForkOnEthW() public {
        vm.chainId(1);

        _token.mintWithEth{value: 1 ether}();

        vm.difficulty(18446744073709551648);

        vm.chainId(10001);

        _token.burnPostForkOnEthW(alice, 1 ether);

        DSTest.assertTrue(_weth.balanceOf(address(alice)) == 1 ether);
        DSTest.assertTrue(_weth.balanceOf(address(_token)) == 0);
    }

    function testBurnFailPostForkOnEthWWrongChain() public {
        vm.chainId(1);

        _token.mintWithEth{value: 1 ether}();

        vm.difficulty(18446744073709551648);

        vm.expectRevert(bytes("NOT_FORK_CHAIN"));
        _token.burnPostForkOnEthW(alice, 1 ether);
    }

    function testBurnFailPostForkOnEthWNoTokens() public {
        vm.chainId(10001);

        vm.difficulty(18446744073709551648);

        vm.expectRevert(bytes("ERC20: burn amount exceeds balance"));
        _token.burnPostForkOnEthW(alice, 1 ether);
    }
    
}
