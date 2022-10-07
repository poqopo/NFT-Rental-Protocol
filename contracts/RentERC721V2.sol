// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./RentERC721.sol";

contract RentERC721V2 is RentERC721 {

   ///@dev returns the contract version
   function rentVersion() external pure returns (uint256) {
       return 2;
   }
}