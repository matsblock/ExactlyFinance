// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ETHPool  {

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    //------
    address public owner;

    mapping (address => uint256) public BalanceOf;
    uint256 public totalBalance;
    uint256 public dividendPerPool;
    mapping (address => uint256) public dividendBalanceOf;

    mapping (address => uint256) public RewardsBalanceOf;
    uint256 public totalRewardsBalance;

    struct depositRegistryStruct{
        uint depositTime;
        uint depositId;
        uint amount;
    }
    mapping (address => depositRegistryStruct[]) public depositRegistry;
    mapping (address => depositRegistryStruct[]) public depositRewardsRegistry;

    constructor() {
        // Set the transaction sender as the owner of the contract.
        owner = msg.sender;
    }

    function deposit() public payable {
        (bool sent, bytes memory data) = address(this).call{value: msg.value}("");
        require(sent, "Failed to send Ether");

        totalBalance += msg.value; 
        BalanceOf[msg.sender] += msg.value;
        uint a;
        
       depositRegistryStruct memory _depositRegistryStruct;

        _depositRegistryStruct.amount = msg.value;
        _depositRegistryStruct.depositTime = block.timestamp;
        _depositRegistryStruct.depositId = depositRegistry[msg.sender].length;
        depositRegistry[msg.sender].push(_depositRegistryStruct);
    }

    function rewardsDeposit() public payable onlyOwner  {
        totalRewardsBalance += msg.value; 
        depositRegistryStruct memory _depositRegistryStruct;

        _depositRegistryStruct.amount = msg.value;
        _depositRegistryStruct.depositTime = block.timestamp;
        _depositRegistryStruct.depositId = depositRewardsRegistry[msg.sender].length;
        depositRewardsRegistry[msg.sender].push(_depositRegistryStruct);

        (bool sent, bytes memory data) = address(this).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    //Withdraw Ether from the contract
    function withdrawDeposit(uint256 amount) public {

    totalBalance -= amount; 
    BalanceOf[msg.sender] -= amount;
    
    (bool succeed, bytes memory data) = msg.sender.call{value: amount}("");
    require(succeed, "Failed to withdraw Ether");
}

function claimRewards() public {
    uint rewards;
    dividendBalanceOf[msg.sender] = BalanceOf[msg.sender]  * 100 / totalBalance;
    RewardsBalanceOf[msg.sender] = dividendBalanceOf[msg.sender] * totalRewardsBalance / 100;
    rewards = RewardsBalanceOf[msg.sender];


    (bool succeed, bytes memory data) = msg.sender.call{value: rewards}("");
    require(succeed, "Failed to withdraw Ether");
}
 
    //Send ether from the account connected with this function
    function sendViaCall(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

 
