// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.22;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./CanvasFactory.sol";

contract Canvas is Ownable {
    struct Pixel {
        uint8 r;
        uint8 g;
        uint8 b;
        address owner;
        uint256 price;
    }

    Pixel[56][56] public pixels;
    bool public ended;
    mapping(address => bool) public claimedRewards;
    bool public usersGetRewarded;

    // will be owned by CanvasFactory
    constructor() Ownable(msg.sender) {
    }

    function buyPixel(uint256 x, uint256 y, uint8 r, uint8 g, uint8 b) public payable {
        require(!ended, "Canvas is ended");
        require(msg.value > pixels[x][y].price, "Not enough money");
        require(msg.sender != pixels[x][y].owner, "You already own this pixel");

        // refund previous owner
        // (currently we don't refund the previous owner)
        // pixels[x][y].owner.transfer(pixels[x][y].price);
        // change owner
        pixels[x][y].owner = msg.sender;
        // change price
        pixels[x][y].price = msg.value;
        // change color
        pixels[x][y].r = r;
        pixels[x][y].g = g;
        pixels[x][y].b = b;
    }

    function end(bool _usersGetRewarded) public onlyOwner {
        require(!ended, "Canvas is already ended");

        ended = true;
        usersGetRewarded = _usersGetRewarded;

        payable(owner()).transfer(address(this).balance);
    }

    function claimRewards() public {
        require(!claimedRewards[msg.sender], "Already claimed");
        require(ended, "Canvas is not ended");
        require(usersGetRewarded, "Users don't get rewarded for this canvas");

        claimedRewards[msg.sender] = true;

        uint256 reward = 0;

        for (uint256 x = 0; x < 56; x++) {
            for (uint256 y = 0; y < 56; y++) {
                if (pixels[x][y].owner == msg.sender) {
                    reward++;
                }
            }
        }

        CanvasFactory(payable(owner())).reward(msg.sender, reward);
    }
}
