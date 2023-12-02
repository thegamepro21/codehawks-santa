// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {SantasList} from "../../src/SantasList.sol";
import {SantaToken} from "../../src/SantaToken.sol";
import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract SantaListTest is Test{

    SantasList santasList;
    SantaToken santaToken;
    address user = makeAddr("user");
    address santa = makeAddr("santa");
    address stranger = makeAddr("stranger");

    function setUp() public {
        vm.startPrank(santa);
        santasList = new SantasList();
        santaToken = new SantaToken(address(santasList));
        vm.stopPrank();
    }


    function test_checkListSanta() public {
        vm.startPrank(santa);
        santasList.checkList(user, SantasList.Status.NICE);
        assertEq(uint256(santasList.getNaughtyOrNiceOnce(user)), uint256(SantasList.Status.NICE));
        
    }

    function test_checkListStranger() public {
        vm.startPrank(stranger);
        santasList.checkList(user, SantasList.Status.NICE);
        assertEq(uint256(santasList.getNaughtyOrNiceOnce(user)), uint256(SantasList.Status.NICE));
        
    }

    function test_checkListStranger_setToExtraNice() public {
        vm.startPrank(stranger);
        santasList.checkList(user, SantasList.Status.EXTRA_NICE);
        assertEq(uint256(santasList.getNaughtyOrNiceOnce(user)), uint256(SantasList.Status.EXTRA_NICE));
        
    }

    function test_checkTwiceStranger() public {
        vm.startPrank(stranger);
        vm.expectRevert();
        santasList.checkTwice(user, SantasList.Status.NICE);
        assertEq(uint256(santasList.getNaughtyOrNiceOnce(user)), uint256(SantasList.Status.NICE));
        
    }

    function test_checkTwiceSanta_will_revert() public {
        vm.startPrank(santa);
        santasList.checkList(user, SantasList.Status.NICE);
        vm.expectRevert();
        santasList.checkTwice(user, SantasList.Status.EXTRA_NICE);
        assertEq(uint256(santasList.getNaughtyOrNiceOnce(user)), uint256(SantasList.Status.NICE));

    }

    function test_collectSample_will_revert() public {
        vm.startPrank(santa);
        // stranger is eligible for present
        santasList.checkList(stranger, SantasList.Status.EXTRA_NICE);
        changePrank(stranger);
        //stranger collects present
         vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);
         vm.expectRevert();
        santasList.collectPresent();

    }
    

    
}
