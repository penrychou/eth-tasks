// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {InsertSort} from "../src/InsertSort.sol";

contract InsertSortTest is Test {
    InsertSort public insertSort;
    uint256[] sortedArr = [1, 3, 4, 6, 7];

    function setUp() public {
        insertSort = new InsertSort();
    }

    function test_Sort() public {
        insertSort.getArr();
        insertSort.sort();
        assertTrue(checkArray(insertSort.getArr(), sortedArr));
    }

    function checkArray(
        uint256[] memory arr1,
        uint256[] memory arr2
    ) internal pure returns (bool) {
        if (arr1.length != arr2.length) {
            return false;
        }
        for (uint256 i = 0; i < arr1.length; i++) {
            if (arr1[i] != arr2[i]) {
                return false;
            }
        }
        return true;
    }
}
