pragma solidity ^0.4.6;

import {Owned} from './Owned.sol';

contract Remittance is Owned{
    uint public ownerBalance;
    uint public ownerCut = 10;
    uint public maxDeadline = 100;
    bool public killed;

    struct Transaction{
        address remitter;
        uint amount;
        uint deadline;
    }

    mapping(bytes32 => Transaction) public transactionList;

    function sendToCarol(bytes32 hash, uint deadline) payable returns (bool) {
        require(!killed);
        require(msg.value > ownerCut);
        require(deadline > 0 && deadline < maxDeadline);
        require(transactionList[hash].amount == 0);

        transactionList[hash] = Transaction(msg.sender, msg.value - ownerCut,
                                            block.number + deadline);
        ownerBalance += ownerCut;
        return true;
    }

    function withdraw(address aliceAddress, string bobPassword) returns (bool) {
        bytes32 hash =  keccak256(msg.sender, aliceAddress, bobPassword);

        require(transactionList[hash].deadline <= block.number);
        require(transactionList[hash].amount > 0);

        uint remittanceAmount = transactionList[hash].amount;
        transactionList[hash].amount = 0;
        msg.sender.transfer(remittanceAmount);

        return true;
    }

    function sendRefund(bytes32 hash) returns (bool) {
        require(transactionList[hash].remitter == msg.sender);
        require(transactionList[hash].deadline > block.number);
        require(transactionList[hash].amount > 0);

        uint refundAmount = transactionList[hash].amount;
        transactionList[hash].amount = 0;
        msg.sender.transfer(refundAmount);

        return true;
    }

    function ownerWithdraw() returns (bool) {
        require(msg.sender == owner);
        require(ownerBalance > 0);
        ownerBalance = 0;
        owner.transfer(ownerBalance);
    }

    function kill() returns (bool) {
        require(!killed);
        require(msg.sender == owner);
        killed = true;
    }
}
