pragma solidity =0.8.22;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/CanvasFactory.sol";
import "../src/Canvas.sol";
import "../src/BlockPlaceToken.sol";

contract CanvasFactoryTest is Test {
    address owner = address(0x100);
    address user1 = address(0x101);
    address user2 = address(0x102);

    CanvasFactory factory;

    function setUp() public {
        vm.prank(owner);
        factory = new CanvasFactory(0, address(0), address(0));

        // give some gas funds to the addresses
        vm.deal(owner, 1e18);
        vm.deal(user1, 1e18);
        vm.deal(user2, 1e18);
    }

    function testNewCanvasReverts() public {
        // it should revert if there is already an active canvas
        vm.prank(owner);
        vm.expectRevert();
        factory.newCanvas();

        // now end the canvas
        vm.prank(owner);
        factory.end();

        // it should revert if someone else tries to create a new canvas
        vm.prank(user1);
        vm.expectRevert();
        factory.newCanvas();
    }

    function testPaymentTransfer() public {
        Canvas canvas = factory.canvas();

        // the user buys a pixel
        vm.prank(user1);
        canvas.buyPixel{value: 1000}(0, 0, 255, 0, 0);

        // another user outbids the first one
        vm.prank(user2);
        canvas.buyPixel{value: 2000}(0, 0, 0, 255, 0);

        // end the canvas
        vm.prank(owner);
        factory.end();

        // the factory should have the balance that the canvas had
        assertEq(address(factory).balance, 3000);

        BlockPlaceToken token = factory.token();

        // user 1 claims the reward
        vm.prank(user1);
        canvas.claimRewards();

        // user 1 should have 0 tokens
        assertEq(token.balanceOf(user1), 0);

        // user 2 claims the reward
        vm.prank(user2);
        canvas.claimRewards();

        // user 2 should have 1 token
        assertEq(token.balanceOf(user2), 1e18);
    }

    function testBidding() public {
        Canvas canvas = factory.canvas();
        
        // the user buys a pixel
        vm.prank(user1);
        canvas.buyPixel{value: 1000}(0, 0, 255, 0, 0);

        // the color should be red
        (uint8 r, uint8 g, uint8 b, address pixelOwner, uint256 price) = canvas.pixels(0, 0);
        assertEq(r, 255);
        assertEq(g, 0);
        assertEq(b, 0);
        assertEq(pixelOwner, user1);
        assertEq(price, 1000);

        // underbidding sould revert
        vm.prank(user2);
        vm.expectRevert();
        canvas.buyPixel{value: 500}(0, 0, 0, 255, 0);
        
        // using the same price should revert
        vm.prank(user2);
        vm.expectRevert();
        canvas.buyPixel{value: 1000}(0, 0, 0, 255, 0);

        // they are then outbid
        vm.prank(user2);
        canvas.buyPixel{value: 2000}(0, 0, 0, 255, 0);

        // the color should be green
        (r, g, b, pixelOwner, price) = canvas.pixels(0, 0);
        assertEq(r, 0);
        assertEq(g, 255);
        assertEq(b, 0);
        assertEq(pixelOwner, user2);
        assertEq(price, 2000);
    }

    /*
    Can't be tested without chainlink being live
    function testNoReward() public {
        Canvas canvas = factory.canvas();

        // the user buys a pixel
        vm.prank(user1);
        canvas.buyPixel{value: 1000}(0, 0, 255, 0, 0);

        // end the canvas
        vm.prank(owner);
        factory.end();

        // user 1 shouldn't get any reward
        vm.prank(user1);
        vm.expectRevert();
        canvas.claimRewards();

        // user 1 should have 0 tokens
        BlockPlaceToken token = factory.token();
        assertEq(token.balanceOf(user1), 0);
    }
    */
}
