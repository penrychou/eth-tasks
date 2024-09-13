// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NftMarketplace} from "../src/NftMarketplace.sol";

contract NftMarketplaceTest is Test {
    function setUp() public {
        NftMarketplaceTest = new NftMarketplace();
    }

    function test_Increment() public {
        insertSort.getArr();
        insertSort.sort();
        assertTrue(checkArray(insertSort.getArr(), sortedArr));
    }
}
