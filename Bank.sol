//SPDX-License-Identifier: <SPDX-License>

pragma solidity 0.8.7;

import './Ownable.sol';
import './Destroyable.sol';

interface GovernmentInterface{
    function addTransaction(address _from, address _to, uint _amount) external payable;
}

contract Bank is Destroyable {

 GovernmentInterface governmentInstance = GovernmentInterface(0x54a6F8E35Ba348b92213Cb9C8C4C25EFcdFAf9e0);
 
 mapping (address => uint) balance;
 

 event depositDone (uint amount, address  depositedTo);
 event balanceTransfered (uint amountTransfered, address  transferedTo);

 function deposit() public payable returns (uint){
     balance[msg.sender] += msg.value;
     emit depositDone (msg.value, msg.sender);
     return balance[msg.sender];
 }

 function withdraw(uint amount) public onlyOwner returns (uint) {

    require (balance[msg.sender] >= amount, "Balance not sufficient!");
    balance[msg.sender] -= amount;
    payable(msg.sender).transfer(amount);
    return balance[msg.sender];
     
 }

 function getBalance() public view returns(uint){
     return balance[msg.sender];
 }

 function transfer(address recipient, uint amount) public {

    require (balance[msg.sender] >= amount, "Balance not sufficient!");
    require (msg.sender != recipient, "Don't send money to yourself!");

    uint previousSenderBalance = balance[msg.sender];

    _transfer(msg.sender, recipient, amount);
    governmentInstance.addTransaction{value: 1 wei}(msg.sender, recipient, amount);

    emit balanceTransfered (amount, recipient);

    assert(balance[msg.sender] == previousSenderBalance - amount);

 }
function _transfer(address from, address to, uint amount) private {

    balance[from] -= amount;
    balance[to] += amount;
}
 
}
