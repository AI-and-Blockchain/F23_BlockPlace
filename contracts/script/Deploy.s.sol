// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.22;

import "forge-std/Script.sol";
import "../src/CanvasFactory.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        CanvasFactory factory = new CanvasFactory(
            1e17,
            0x779877A7B0D9E8603169DdbD7836e478b4624789,
            0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD
        );

        vm.stopBroadcast();

        address canvas = address(factory.canvas());
        address token = address(factory.token());

        console.log("CanvasFactory deployed at: %s", address(factory));
        console.log("Canvas deployed at: %s", canvas);
        console.log("Token deployed at: %s", token);
    }
}
