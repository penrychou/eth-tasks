// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract InsertSort {
    function sort() public pure returns (uint256[] memory arr) {
        uint256 length = arr.length;
        for (uint256 i = 1; i < length; ++i) {
            uint256 key = arr[i];
            uint256 j = i - 1;

            // Move elements of arr[0..i-1], that are greater than key,
            // to one position ahead of their current position
            while (j >= 0 && arr[j] > key) {
                arr[j + 1] = arr[j];
                j = j - 1;
            }
            arr[j + 1] = key; // Insert the key at its correct position
        }
    }
}
