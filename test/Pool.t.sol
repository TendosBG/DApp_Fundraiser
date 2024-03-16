// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Test.sol";
import { Pool } from "../src/Pool.sol";

contract PoolTest is Test{
    address owner = makeAddr("User0");
    address user = makeAddr("User1");
    address user2 = makeAddr("User2");
    address user3 = makeAddr("User3");

    uint256 duration = 4 weeks;
    uint256 goal = 10 ether;

    Pool pool;

    // Define the event at the contract level
    event LogTimestamp(bytes32 message);


    function setUp() public {
        vm.prank(owner);
        pool = new Pool(duration, goal);
        
    }

    function test_ContractDeployedSuccessfully() public view {
        assertEq(pool.owner(), owner);
        assertEq(pool.end(), block.timestamp + duration);
        assertEq(pool.goal(), goal);
        assertEq(pool.totalCollected(), 0);
    }

    // Contribute

    function test_RevertWhen_EndIsReached() public {
        vm.warp(pool.end() +3600);
        
        
        bytes4 selector = bytes4(keccak256("CollectIsFinished()"));
        
        vm.expectRevert(abi.encodeWithSelector(selector));

        vm.prank(user);
        vm.deal(user, 1 ether);
        pool.contribute{value: 1 ether}();

    }

}