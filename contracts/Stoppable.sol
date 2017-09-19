pragma solidity ^0.4.6;

import "./Owned.sol";

contract Stoppable is Owned {
    
    bool public running;
    
    event LogRunValueChanged(bool runState);
    
     modifier onlyIfRunning {
         require(running); 
         _; 
    }
    
    function Stoppable(){
        running = true;
    }
    
     function runSwitch(bool onOff)
        onlyOwner
        returns(bool)
    {
        running = onOff;
        LogRunValueChanged(running);
        return true;
    }
    
    
}

