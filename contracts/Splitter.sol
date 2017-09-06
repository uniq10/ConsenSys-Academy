pragma solidity ^0.4.6;

import {Owned} from './Owned.sol';

contract Splitter is Owned{
    mapping(address => uint) public balances;
    bool public killed;

    function kill() returns (bool) {
        require(msg.sender == owner);
        killed = true;
    }

    function withdraw() returns (bool) {
        require(balances[msg.sender] > 0);
        balances[msg.sender] = 0;
        msg.sender.transfer(balances[msg.sender]);
        return true;
    }

    function sendMoney(address a1, address a2) payable returns (bool) {
        require(!killed);
        require(a1 != 0 && a2 != 0);
        require(msg.value > 0);

        uint amount = msg.value;
        if(amount%2 != 0) {
            balances[msg.sender] += 1;
            amount--;
        }

        balances[a1] += amount/2;
        balances[a2] += amount/2;

        return true;
    }
}
