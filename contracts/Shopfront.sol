pragma solidity ^0.4.6;

import './Stoppable.sol';

contract Storefront is Stoppable {
    
    address owner;
    uint contractBalance;
    
    event LogCustomerBought(uint productId, uint quantity);
    
    event LogOwnerTransfer(uint amount);
    event LogKill(address currOwner, uint blockNumber);
    
    event LogPaidAdmin(address admin, uint amount);
    event LogAddedAdmin(address admin);
    
    event LogAddedProduct(uint productId, uint price, uint quantity);
    event LogChangedPrice(uint productId, uint price);
    event LogAddedQuantity(uint productId, uint quantity);
    event LogDeletedProduct(uint productId);
    
    event LogAddedNewSplitPayment(address sender, bytes32 key, uint productId, uint quantity, uint amountPaid);
    event LogPaidPartOfSplitPayment(address sender, bytes32 key, uint amountPaid);
    event LogSplitItemBought(address sender, bytes32 key, uint productId, uint quantity, uint amountPaid);
    
    struct ProductDetails {
        uint costPerItem;
        uint stockAvl;
        bool exists;
        address admin;
    }
    
    struct Admins {
        bool isAdmin;
        uint numOfItems;
        uint amtPayable;
    }
    
    struct SplitPaymentDetails {
        uint amountCollected;
        uint pid;
        uint qty;
        uint totalAmountToPay;
        bool sentItem;
    }
    
    mapping(uint => ProductDetails) public productsAvl;
    mapping(address => Admins) allAdmins;
    mapping(bytes32 => SplitPaymentDetails) splitPaymentDetails;
    
    modifier onlyAdmin() {
        require(allAdmins[msg.sender].isAdmin);
        _;
    }
    
    function Storefront() {
        
    }
    
    function buy(uint pid, uint qty) 
        public
        payable 
        returns(bool) 
    {
        ProductDetails memory p = productsAvl[pid];
        require(p.stockAvl >= qty);
        require(msg.value == qty*p.costPerItem);
        
        p.stockAvl -= qty;
        allAdmins[p.admin].amtPayable += msg.value;
        
        LogCustomerBought(pid,qty);
        return true;
    }
    
    function withdraw(uint amt)
        onlyOwner
        returns(bool)
    {
        require(contractBalance >= amt);
        
        contractBalance -= amt;
        owner.transfer(amt);
        
        LogOwnerTransfer(amt);
        return true;
    }
    
    function payAdmin(address a1)
        onlyOwner
        returns(bool)
    {
        require(allAdmins[a1].amtPayable > 0);
        
        uint amt = allAdmins[a1].amtPayable; 
        allAdmins[a1].amtPayable = 0;
        a1.transfer(amt);
        
        LogPaidAdmin(a1,amt);
        return true;
    }
    
    function addProduct(uint pid, uint price, uint qty)
        onlyAdmin
        returns(bool)
    {
        require(qty>0);
        require(!p.exists);
        
        ProductDetails memory p = productsAvl[pid];
        
        allAdmins[msg.sender].numOfItems+=1;
        p.admin = msg.sender;
        p.exists = true;
        p.costPerItem = price;
        p.stockAvl += qty;
        
        LogAddedProduct(pid,price,qty);
        return true;
    }
    
    function changePrice(uint pid, uint price)
        onlyAdmin
        returns(bool)
    {
        ProductDetails memory p = productsAvl[pid];
        require(p.admin == msg.sender);
        p.costPerItem = price;
        
        LogChangedPrice(pid,price);
        return true;
    }
    
    function addQty(uint pid, uint qty)
        onlyAdmin
        returns(bool)
    {
        ProductDetails memory p = productsAvl[pid];
        require(p.admin == msg.sender);
        p.stockAvl += qty;
        
        LogAddedQuantity(pid,qty);
        return true;
    }
    
    function removeProduct(uint pid)
        onlyAdmin
        returns(bool)
    {
        ProductDetails memory p = productsAvl[pid];
        
        require(p.admin == msg.sender);
        require(p.exists);
        
        p.exists = false;
        p.costPerItem = 0;
        p.stockAvl = 0;
        
        LogDeletedProduct(pid);
        return true;
    }
    
    function addAdmin(address a)
        onlyOwner
        returns(bool)
    {
        allAdmins[a].isAdmin = true;
        
        LogAddedAdmin(a);
        return true;
    }
    
    function addSplitPayment(bytes32 key, uint pid, uint qty)
        public
        payable
        returns(bool)
    {
        SplitPaymentDetails memory s = splitPaymentDetails[key];
        require(s.pid==0 || s.sentItem);
        
        s.pid = pid;
        s.qty = qty;
        s.amountCollected += msg.value;
        s.totalAmountToPay = qty * productsAvl[pid].costPerItem;
        
        LogAddedNewSplitPayment(msg.sender, key, pid, qty, msg.value);
        return true;
    }
    
    function contributeForSplitPayment(bytes32 key)
        public
        payable
        returns(bool)
    {
        require(msg.value > 0);
        
        SplitPaymentDetails memory s = splitPaymentDetails[key];
        require(!s.sentItem);
        require(s.totalAmountToPay != 0);
        
        s.amountCollected += msg.value;
        LogPaidPartOfSplitPayment(msg.sender, key, msg.value);
        return true;
    }
    
    function getItemOncePaymentComplete(bytes32 key)
        public
        returns(bool)
    {
        SplitPaymentDetails memory s = splitPaymentDetails[key];
        require(!s.sentItem);
        require(s.totalAmountToPay != 0);
        
        uint amt = s.totalAmountToPay - s.amountCollected;
        require(amt==0);
        s.sentItem = true;
        
        ProductDetails memory p = productsAvl[s.pid];
        p.stockAvl -= s.qty;
        allAdmins[p.admin].amtPayable += s.amountCollected;
        
        LogSplitItemBought(msg.sender, key, s.pid, s.qty, s.amountCollected);
        return true;
    }
    
}

