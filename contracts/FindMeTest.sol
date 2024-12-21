// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundMeTest {

    mapping (address => uint256) public funderToAmount;


    // uint256 MINIMUM_VALUE = 1 * 10 ** 18; //wei

    uint256 constant MINIMUM_VALUE = 100 * 10 ** 18; //usd

    uint256 constant TARGET = 1000 * 10 ** 18;

    address public owner;

    uint256 deploymentTimestamp;
    uint256 lockTime;

    address erc20Addr;

    bool public getFundSuccess;


    constructor(uint256 _lockTime) {
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
    }


    function fund() external payable {
        require(converEthToUsd(msg.value) >= MINIMUM_VALUE, "send More ETH");
        require(block.timestamp < deploymentTimestamp + lockTime, "window is closed");
        
        uint256 amount = funderToAmount[msg.sender];
        if (amount == uint256(0x0)) {
            funderToAmount[msg.sender] = msg.value;
        } else {
            funderToAmount[msg.sender] = amount + msg.value;
        }
        
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public pure returns (int) {
        return 3859 * 10 ** 8;
    }

    function converEthToUsd(uint256 ethAmount) internal pure returns(uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethAmount * ethPrice / (10 ** 8);
    }

    function getFund() external windowClose onlyOwner {
        require(converEthToUsd(address(this).balance) >= TARGET, "Target  is not reached");
        
        //transfer
        // payable(msg.sender).transfer(address(this).balance);
        //send
        // bool success = payable(msg.sender).send(address(this).balance);
        // require(success, "tx failed");
        //call
        bool success;
        (success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "tx is failed");
        funderToAmount[msg.sender] = 0;

        getFundSuccess = true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function refund() external windowClose {
        require(converEthToUsd(address(this).balance) < TARGET, "Target is reached");
        require(funderToAmount[msg.sender] != 0, "there is no fund for you");

        bool success;
        (success, ) = payable(msg.sender).call{value: funderToAmount[msg.sender]}("");
        require(success, "tx is failed");
        funderToAmount[msg.sender] = 0;
    }

    function setFunderToAmount(address funder, uint256 amountToUpdate) external {
        require(msg.sender == erc20Addr, "you do not have permission to call this funtion");
        funderToAmount[funder] = amountToUpdate;
    }

    function setErc20Addr(address _ecr20Addr) public onlyOwner {
        erc20Addr = _ecr20Addr;
    }

    modifier windowClose() {
        require(block.timestamp >= deploymentTimestamp + lockTime, "window is not closed");
        _;
    }

    modifier onlyOwner() {
       require(msg.sender == owner, "this function can only be called by owner");
        _;
    }

    
}