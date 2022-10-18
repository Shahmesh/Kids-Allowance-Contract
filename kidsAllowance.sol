// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract kidsAllowance {

    address public owner;

    constructor() {
        owner == msg.sender;
    }

    mapping(address => uint) public allowance;
    mapping(address => bool) public isAllowedToSend;

    struct Kids {
        address payable walletAddress;
        string name;
        uint releaseTime;
        bool canWithdraw; 
        uint amount;
    }

    Kids[] public kids;

    function addKid(address payable walletAddress, string memory name,
     uint releaseTime, bool canWithdraw, uint amount) public {
        kids.push(
            Kids(
                walletAddress,
                name,
                releaseTime,
                canWithdraw,
                amount
            )
        );
    }

    function setAllowance(address _for, uint _amount) public {
        require(msg.sender == owner, "Caller is not owner, aborting");
        allowance[msg.sender] = _amount;

        if(_amount > 0) {
            isAllowedToSend[_for] = true;
        } else {
            isAllowedToSend[_for] = false;
        }
    }

    function deposit(address walletAddress) public payable {
        addToKidsBalance(walletAddress);
    }


    function addToKidsBalance(address walletAddress) private {
        for (uint i = 0; i < kids.length; i++) {
            if(kids[i].walletAddress == walletAddress) {
                kids[i].amount += msg.value;
            }
        }
    }

    function getIndex(address walletAddress) view private returns(uint) {
        for (uint i = 0; i < kids.length; i++) {
            if(kids[i].walletAddress == walletAddress) {
                return i;
            }
        }
        return 999;
    } 

    function ableToWithdraw(address walletAddress) public returns(bool) {
        uint i = getIndex(walletAddress);
        if (block.timestamp > kids[i].releaseTime) {
            kids[i].canWithdraw = true;
            return true;
        } else {
            return false;
        }
    } 

    function withdrawFunds(address walletAddress) payable public {
        uint i = getIndex(walletAddress);
        require(msg.sender == kids[i].walletAddress, "You must be the kid to withdraw");
        kids[i].walletAddress.transfer(kids[i].amount);
    }

}