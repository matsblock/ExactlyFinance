// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ETHPool  {

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}
    uint public _rewards;
    uint public userRewards;
    uint public _totalUserDepositsInThisReward;
//    uint public depositsLength;
    //------
    address public owner;

    mapping (address => uint) public BalanceOf;
    uint public totalUsersBalance;

    uint256 public totalRewardsBalance;

    struct depositRegistryStruct{
         uint depositTime;
         uint depositId;
         uint amount;
         uint totalBalanceAtThisTime;
//         uint balanceAtThisTime;


     }
    mapping (address => depositRegistryStruct[]) public depositsUserRegistry;
    depositRegistryStruct[] public rewardsDepositsRegistry;
    mapping (address => uint) public lastClaim;


    // mapping (address => uint256) public lastClaim;

    constructor() {
        // Set the transaction sender as the owner of the contract.
        owner = msg.sender;
 //       lastClaim[msg.sender] = 0;
    }

    function userDeposit() public payable {
        totalUsersBalance += msg.value; 
        BalanceOf[msg.sender] += msg.value;
        depositRegistryStruct memory userDeposit;

         userDeposit.amount = msg.value;
         userDeposit.depositTime = block.timestamp;
         userDeposit.depositId = depositsUserRegistry[msg.sender].length;
         userDeposit.totalBalanceAtThisTime = totalUsersBalance;
         depositsUserRegistry[msg.sender].push(userDeposit);

        (bool sent, bytes memory data) = address(this).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    // function userDeposit(address _address ,uint _depositId) public returns (depositRegistryStruct memory) {
    //     return depositsUserRegistry[_address][_depositId];
    // }

    function rewardsDeposit() public payable onlyOwner  {
        totalRewardsBalance += msg.value; 
        depositRegistryStruct memory rewardDeposit;

         rewardDeposit.amount = msg.value;
         rewardDeposit.depositTime = block.timestamp;
         rewardDeposit.depositId = rewardsDepositsRegistry.length;
         rewardDeposit.totalBalanceAtThisTime = totalUsersBalance;
         rewardsDepositsRegistry.push(rewardDeposit);

        (bool sent, bytes memory data) = address(this).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    // function rewardDeposit(uint _depositId) public returns (depositRegistryStruct memory) {
    //     return rewardsDepositsRegistry[_depositId];
    // }

    //Withdraw Ether from the contract
    function withdrawDeposit(uint amount) public {
        totalUsersBalance -= amount; 
        BalanceOf[msg.sender] -= amount;
        
         (bool succeed, bytes memory data) = msg.sender.call{value: amount}("");
         require(succeed, "Failed to withdraw Ether");
}


 function calculateRewards() public returns (uint)  {
    uint rewards; 
    uint totalUserDeposits; 
    uint proportionRewards;

        for (uint i = rewardsDepositsRegistry.length; i > 0 ; i--) {  
            if (lastClaim[msg.sender] < rewardsDepositsRegistry[i - 1].depositTime) {
                totalUserDeposits = calculateTotalUserDepositsInReward(i - 1);
                proportionRewards += totalUserDeposits * 100 /  rewardsDepositsRegistry[i-1].totalBalanceAtThisTime * rewardsDepositsRegistry[i-1].amount;
            }
            else {
                _rewards = 0;
                break;
            }      
//               _rewards = i - 1;
    }

//            rewards = proportionRewards;
            _rewards = proportionRewards;
            lastClaim[msg.sender]=block.timestamp;
            return _rewards;
        }

function calculateTotalUserDepositsInReward(uint i) public returns (uint){
    uint totalUserDepositsInThisReward = 0; 
            for (uint j = 0 ; j < depositsUserRegistry[msg.sender].length; j++){
                    if (rewardsDepositsRegistry[i].depositTime > depositsUserRegistry[msg.sender][j].depositTime){
                        totalUserDepositsInThisReward +=  depositsUserRegistry[msg.sender][j].amount;
                     } 
                     else {
                         break;
                        }
                }
        _totalUserDepositsInThisReward = totalUserDepositsInThisReward;
        return totalUserDepositsInThisReward;
    }


function claimRewards() public {
    uint rewards;
    rewards = calculateRewards() / 100;
    lastClaim[msg.sender] = block.timestamp;

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

    function getLegthDepositsArray() public view returns (uint){
        return  depositsUserRegistry[msg.sender].length;
    }

    

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    function testSomething() public returns (uint) {
        uint i = 1;
        return  (i - 1);
    }
 
}
 
