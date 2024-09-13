// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

contract InsertSort {
    uint256[] public arr = [7, 6, 4, 3, 1];

    function sort() public {
        uint256 length = arr.length;
        for (uint256 i = 1; i < length; ++i) {
            uint256 key = arr[i];
            uint256 j = i - 1;
            bool f = false;

            // 将比key大的元素向后移动一位
            while (j >= 0 && arr[j] > key) {
                arr[j + 1] = arr[j];
                if (j == 0) {
                    f = true;
                    break;
                }
                j--;
            }
            if (f) {
                arr[0] = key;
            } else {
                arr[j + 1] = key;
            }
            // 将key放置在正确的位置
        }
    }

    function getArr() public view returns (uint256[] memory) {
        return arr;
    }
}
