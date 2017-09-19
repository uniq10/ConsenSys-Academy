pragma solidity ^0.4.6;

contract Owned{
    
    address public owner;
    
    event LogOwnerChanged(address sender, address a1, address a2);
    
    modifier onlyOwner {
        require(msg.sender==owner);
        _; 
    }
    
    function Owned(){
        owner = msg.sender;
    }
    
    function changeOwner(address newOwner)
        onlyOwner
        returns(bool)
    {
        require(newOwner!=0);
        LogOwnerChanged(msg.sender,owner,newOwner);
        owner = newOwner;
        return true;
        
    }
    
}

