// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {SantasList} from "../../src/SantasList.sol";
import {SantaToken} from "../../src/SantaToken.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract SantaListTest is Test{

    SantasList santasList;
    SantaToken santaToken;
    address user = makeAddr("user");
    address santa = makeAddr("santa");
    address stranger = makeAddr("stranger");
    address caro = makeAddr("caro");

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

    function collect() internal {
        vm.startPrank(santa);
        // we pass in extranice here so the checkTwice function wont revert
        santasList.checkList(stranger, SantasList.Status.EXTRA_NICE);
        santasList.checkTwice(stranger, SantasList.Status.EXTRA_NICE);
        changePrank(stranger);
        //stranger collects present
         vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);
        santasList.collectPresent();
    }

    function test_collectPresent_() public {
        vm.startPrank(santa);
        // we pass in extranice here so the checkTwice function wont revert
        santasList.checkList(stranger, SantasList.Status.EXTRA_NICE);
        santasList.checkTwice(stranger, SantasList.Status.EXTRA_NICE);
        changePrank(stranger);
        //stranger collects present
         vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);
        santasList.collectPresent();

    }

    function test_collectPresent_user_keep_withdrawing() public {
        vm.startPrank(santa);
        santasList.checkList(user, SantasList.Status.NICE);
        changePrank(user);
        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);
        santasList.collectPresent();
        IERC721(address(santasList)).transferFrom(user, stranger, 0);
        santasList.collectPresent();
         IERC721(address(santasList)).transferFrom(user, stranger, 1);
        santasList.collectPresent();
         IERC721(address(santasList)).transferFrom(user, stranger, 2);
        santasList.collectPresent();
         IERC721(address(santasList)).transferFrom(user, stranger, 3);
        console.log(IERC721(address(santasList)).balanceOf(stranger));
        assertEq(IERC721(address(santasList)).balanceOf(stranger), 4);
       

    }

        function test_dos_naive_user_trying_to_claim_reward() public {
        vm.startPrank(santa);
        santasList.checkList(stranger, SantasList.Status.NICE);
        santasList.checkList(user, SantasList.Status.NICE);
        changePrank(stranger);
        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);
        santasList.collectPresent();
        IERC721(address(santasList)).transferFrom(stranger, user, 0);
        //naive user trying to collect present
        changePrank(user);
        vm.expectRevert();
        santasList.collectPresent();

        }

        function test_dos_naive_user_by_setting_their_checkList_status() public {
            vm.startPrank(santa);
            santasList.checkList(user, SantasList.Status.NICE);
            changePrank(stranger);
            santasList.checkList(user, SantasList.Status.NAUGHTY);
            changePrank(user);
            vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);
            santasList.collectPresent();
            //no nft is minted
            assertEq(IERC721(address(santasList)).balanceOf(stranger), 0);
            
        }

        function _collectPresentManyTimes() internal {
        vm.startPrank(santa);
        // we pass in extranice here so the checkTwice function wont revert
        santasList.checkList(stranger, SantasList.Status.EXTRA_NICE);
        santasList.checkTwice(stranger, SantasList.Status.EXTRA_NICE);
        changePrank(user);
        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);
        //User keep minting and getting tokens and nft 4 times
        santasList.collectPresent();
        IERC721(address(santasList)).transferFrom(user, stranger, 0);
        santasList.collectPresent();
         IERC721(address(santasList)).transferFrom(user, stranger, 1);
        santasList.collectPresent();
         IERC721(address(santasList)).transferFrom(user, stranger, 2);
        santasList.collectPresent();
         IERC721(address(santasList)).transferFrom(user, stranger, 3);
        
        }

        function test_buyPresent() internal {
            test_collectPresent_();
            IERC721(address(santasList)).transferFrom(stranger, user, 0);
            santasList.collectPresent();
            IERC721(address(santasList)).transferFrom(stranger, user, 1);
            santasList.collectPresent();
             IERC721(address(santasList)).transferFrom(stranger, user, 2);
            santasList.collectPresent();
             IERC721(address(santasList)).transferFrom(stranger, user, 3);
    
        }

        function test_userBuyPresentFor1eth() public {
            //mint 5e18 eth worth of token for stranger
            test_buyPresent();
            vm.startPrank(stranger);
            //stranger buys present for 1 eth instead of 2 eth worth of tokens
            santasList.buyPresent(stranger);
            assertEq(santasList.balanceOf(stranger), 1);

        }


        function test_MintPresentWithuserAddress() public {
            //mint 5e18 to stranger, caro has none
            test_buyPresent();
            vm.startPrank(caro);
            santasList.buyPresent(stranger);
            assertEq(santasList.balanceOf(caro), 1);
        }


        function test_mintToSelfInsteadOfFriend() public {
            //mint 5e18 to stranger, user has none 
            test_buyPresent();
            //buy present for caro
            vm.expectRevert();
            santasList.buyPresent(caro);
        }

        function test_attackerCanDosByCheckListOnce() public {
             vm.startPrank(santa);
            santasList.checkList(user, SantasList.Status.NICE);
            //attacker set user checkonce status to extranice
            changePrank(stranger);
            santasList.checkList(user, SantasList.Status.EXTRA_NICE);
            //user trying to collect present
            changePrank(user);
             vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);
            santasList.collectPresent();
            //user dies not get any present
            assertEq(IERC721(address(santasList)).balanceOf(user), 0);
        }
}
