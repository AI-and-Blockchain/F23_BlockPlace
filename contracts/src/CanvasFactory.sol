// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./Canvas.sol";
import "./BlockPlaceToken.sol";

contract CanvasFactory is Ownable {
    Canvas public canvas;
    BlockPlaceToken public token;
    mapping(address => bool) public canvases;

    constructor() Ownable(msg.sender) {
        canvas = new Canvas();
        token = new BlockPlaceToken();

        canvases[address(canvas)] = true;
    }

    function end(bool usersGetRewarded) public onlyOwner {
        canvas.end(usersGetRewarded);
    }

    function newCanvas() public onlyOwner {
        // you can only create a new canvas if the previous one has ended
        require(canvas.ended(), "Canvas is not ended");

        canvas = new Canvas();

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
}
