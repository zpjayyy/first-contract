// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "./IERC20.sol";

contract Faucet {
    uint256 public amountAllowed = 100;

    address public tokenContract;

    mapping(address => bool) public requestedAddress;

    event SendToken(address indexed Reveiver, uint256 indexed Amount);

    constructor(address _tokenContract) {
        tokenContract = _tokenContract;
    }    

    function requestTokens() external {
        require(requestedAddress[msg.sender] == false, "Can't request multiple times!!!");
        IERC20 token = IERC20(tokenContract);
        require(token.balanceOf(address(this)) >= amountAllowed, "Faucet empty!!!");

        token.transfer(msg.sender, amountAllowed);
        requestedAddress[msg.sender] = true;

        emit SendToken(msg.sender, amountAllowed);
    }
}