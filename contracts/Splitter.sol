pragma solidity ^0.4.6;

contract Splitter {

    mapping(address => uint) public balances;
    bool public killed;
    address public owner;

    function Splitter() {
        owner = msg.sender;
    }

    function kill() returns(bool) {
        require(msg.sender == owner);
        killed = true;
    }

    function withdraw() returns(bool) {
        address sender = msg.sender;
        require(balances[sender] > 0);
        sender.transfer(balances[sender]);
        return true;
    }

    function sendMoney(address a1, address a2) payable returns(bool) {
        require(!killed);
        require(a1 != 0 && a2 != 0);
        require(amt > 0);

        uint amt = msg.value;

        if(amt%2 != 0) {
            balances[owner] += 1;
            amt--;
        }

        balances[a1] += amt/2;
        balances[a2] += amt/2;

        return true;
    }
}
