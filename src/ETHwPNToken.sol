// SPDX-License-Identifier: Apache 2.0

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./IWETH.sol";

pragma solidity 0.8.17;

contract ETHwPNToken is ERC20 {

    address owner;
    address public immutable WETH;

    mapping(address => uint256) originalOwnerNotes;

    event Mint(address indexed sender, uint256 amount);

    constructor(address _WETH) ERC20("ETHw Promissory Note", "ETHwPN") {
        owner = msg.sender;
        WETH = _WETH;
    }

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier isEthereumMainnetPreFork() {
        assert(block.chainid == 1 && 2**64 >= block.difficulty);
        _;
    }

    modifier isEthereumMainnetPostFork() {
        assert(block.chainid == 1);

        // set as a fail-safe for October 15th, let any owner burn at that point
        if (1665840433 >= block.timestamp) {
            assert(block.difficulty > 2**64);
        }
        _;
    }

    modifier isEthereumWPostFork() {
        assert(block.chainid == 10001);
        _;
    }

    function mint(uint256 amount) public isEthereumMainnetPreFork() {
        assert(IWETH(WETH).transferFrom(msg.sender, address(this), amount));

        __mint(msg.sender, amount);
    }

    function mintWithEth() public payable isEthereumMainnetPreFork() {
        IWETH(WETH).deposit{value: msg.value}();

        __mint(msg.sender, msg.value);
    }

    function __mint(address orig, uint256 amount) internal lock() {
        originalOwnerNotes[msg.sender] += amount;

        _mint(msg.sender, amount);

        emit Mint(msg.sender, amount);
    }

    // post-fork chainid = 1 burn
    function burnPostForkOnEth(address to, uint256 amount) public isEthereumMainnetPostFork() {
        require(originalOwnerNotes[msg.sender] >= amount, "NO_BAL");

        originalOwnerNotes[msg.sender] -= amount;

        assert(IWETH(WETH).transfer(to, amount));
    }

    // post-fork chainid = 1001 burn
    function burnPostForkOnEthW(address to, uint256 amount) public isEthereumWPostFork() {
        _burn(msg.sender, amount);

        assert(IWETH(WETH).transfer(to, amount));
    }

    function burnPreForkOnEth(address to, uint256 amount) public isEthereumMainnetPreFork() {
        assert(transferFrom(msg.sender, address(this), amount));
        require(originalOwnerNotes[msg.sender] >= amount, "NO_NOTE");

        _burn(address(this), amount);

        // this would error above but this function is intended for the owner to burn
        // to get their eth back
        originalOwnerNotes[msg.sender] -= amount;

        assert(IWETH(WETH).transfer(to, amount));
    }

    // solely used to recover errant ERC20 transfers
    function recoverERC20(address erc20contract, address to, uint256 amount) public {
        assert(msg.sender == owner);

        // do not allow recovery of WETH or this token
        assert(address(this) != erc20contract && erc20contract != WETH);

        IERC20(erc20contract).transfer(to, amount);
    }

    // ETH should never be sent to this contract
    function recoverETH(address to, uint256 amount) public {
        assert(msg.sender == owner);

        (bool sent, ) = to.call{value: amount}("");
        require(sent, "FAIL_ETH_SEND");
    }
}
