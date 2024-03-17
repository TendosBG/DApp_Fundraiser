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

    /// @notice Test that the contract reverts when the user sends 0 ether
    function test_RevertWhen_NotEnoughFunds() public {
        bytes4 selector = bytes4(keccak256("NotEnoughFunds()"));
        
        vm.expectRevert(abi.encodeWithSelector(selector));

        vm.prank(user);
        pool.contribute{value: 0}();
    }

    /// @notice Test that we can properly contribute to the pool
    function test_ExpectEmit_SuccessfullyContribute(uint96 _amount) public{
            vm.assume(_amount > 0);
            vm.expectEmit(true, false, false, true);
            emit Pool.Contribute(address(user), _amount);

            vm.prank(user);
            vm.deal(user, _amount);
            pool.contribute{value: _amount}();
        }
    

    /// @notice check that the address that contributed is correct in the contributions mapping
    function test_ContributionsMapping() public {
        vm.prank(user);
        vm.deal(user, 1 ether);
        pool.contribute{value: 1 ether}();

        assertEq(pool.contributions(user), 1 ether);
    }


    // Withdraw

    /// @notice Test that the contract reverts when it's not the owner that calls the withdraw function
    function test_RevertWhen_NotTheOwner() public {
        bytes4 selector = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));
        
        vm.expectRevert(abi.encodeWithSelector(selector, user));

        vm.prank(user);
        pool.withdraw();
    }

    /// @notice Test that the contract reverts when the end is not reached
    function test_RevertWhen_EndIsNotReached() public {
        bytes4 selector = bytes4(keccak256("CollectNotFinished()"));
        
        vm.expectRevert(abi.encodeWithSelector(selector));

        vm.prank(owner);
        pool.withdraw();
    }

    /// @notice Test that the contract reverts when the totalCollected is less than the goal
    function test_RevertWhen_GoalIsNotReached() public {
        vm.prank(user);
        vm.deal(user, 5 ether);
        pool.contribute{value: 5 ether}();

        vm.warp(pool.end() + 3600);

        bytes4 selector = bytes4(keccak256("CollectNotFinished()"));
        vm.expectRevert(abi.encodeWithSelector(selector));

        vm.prank(owner);
        pool.withdraw();
    }

    function test_RevertWhen_GoalReachedButEndNotReached() public{
        vm.prank(user);
        vm.deal(user, 11 ether);
        pool.contribute{value: 11 ether}();

        bytes4 selector = bytes4(keccak256("CollectNotFinished()"));
        vm.expectRevert(abi.encodeWithSelector(selector));
        vm.prank(owner);
        pool.withdraw();
    }


    function test_RevertWhen_WithdrawFailedToSendEther() public {
        pool = new Pool(duration, goal);
        vm.prank(user);
        vm.deal(user, 6 ether);
        pool.contribute{value: 6 ether}();
        vm.prank(user2);
        vm.deal(user2, 5 ether);
        pool.contribute{value: 5 ether}();

        vm.warp(pool.end() + 3600);

        bytes4 selector = bytes4(keccak256("FailedToSendEther()"));
        vm.expectRevert(abi.encodeWithSelector(selector));

        pool.withdraw();
    }

    function test_withdraw() public {
        vm.prank(user);
        vm.deal(user, 6 ether);
        pool.contribute{value: 6 ether}();
        vm.prank(user2);
        vm.deal(user2, 5 ether);
        pool.contribute{value: 5 ether}();

        vm.warp(pool.end() + 3600);

        vm.prank(owner);
        pool.withdraw();
    }

    //reprendre à 1h35m30s

}