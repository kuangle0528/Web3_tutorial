// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract FundMe {

    mapping (address => uint256) public funderToAmount;


    // uint256 MINIMUM_VALUE = 1 * 10 ** 18; //wei

    uint256 constant MINIMUM_VALUE = 1 * 10 ** 18; //usd

    AggregatorV3Interface internal dataFeed;

    uint256 constant TARGET = 10 * 10 ** 18;

    address public owner;

    uint256 deploymentTimestamp;
    uint256 lockTime;

    address erc20Addr;

    bool public getFundSuccess;

    /**
     * Network: Sepolia
     * Aggregator: BTC/USD
     * Address: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
     */
    constructor(uint256 _lockTime) {
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306 
        );
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
    }


    function fund() external payable {
        require(converEthToUsd(msg.value) >= MINIMUM_VALUE, "send More ETH");
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
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function converEthToUsd(uint256 ethAmount) internal view returns(uint256) {
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