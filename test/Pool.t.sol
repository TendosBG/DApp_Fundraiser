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

}