// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./Canvas.sol";
import "./BlockPlaceToken.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract CanvasFactory is Ownable {
    Canvas public canvas;
    BlockPlaceToken public token;
    mapping(address => bool) public canvases;
    uint256 public minScore;
    address public chainlinkToken;
    address public chainlinkOracle;

    constructor(
        uint256 _minScore,
        address _chainlinkToken,
        address _chainlinkOracle
    ) Ownable(msg.sender) {
        minScore = _minScore;
        chainlinkToken = _chainlinkToken;
        chainlinkOracle = _chainlinkOracle;
        canvas = new Canvas(_minScore, _chainlinkToken, _chainlinkOracle);
        token = new BlockPlaceToken();

        canvases[address(canvas)] = true;
    }

    function end(bool usersGetRewarded) public onlyOwner {
        canvas.end(usersGetRewarded);
    }

    function newCanvas() public onlyOwner {
        // you can only create a new canvas if the previous one has ended
        require(canvas.ended(), "Canvas is not ended");

        withdrawLink();

        canvas = new Canvas(minScore, chainlinkToken, chainlinkOracle);

        canvases[address(canvas)] = true;
    }

    function reward(address to, uint256 amount) public {
        // only canvases can reward
        require(canvases[msg.sender], "Not a canvas");

        token.mint(to, 1e18 * amount);
    }
    
    receive() external payable {
        // only canvases can send their balance to the factory
        require(canvases[msg.sender], "Not a canvas");
    }

    function withdrawLink() public onlyOwner {
        canvas.withdrawLink();
        uint256 balance = ERC20(chainlinkToken).balanceOf(address(this));
        ERC20(chainlinkToken).transfer(msg.sender, balance);
    }
}
