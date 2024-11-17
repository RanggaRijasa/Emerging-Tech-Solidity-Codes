// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BagiBagiApplication {
    address public owner;
    uint256 public giveawayPool;
    mapping(address => uint256) public coupons;
    mapping(address => bool) public winners;

    event DonationReceived(address indexed donor, uint256 amount);
    event WinnerAssigned(address indexed winner);
    event CouponClaimed(address indexed claimer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyWinner() {
        require(winners[msg.sender], "Not a giveaway winner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to donate Ether and receive a giveaway coupon
    function donate() external payable {
        require(msg.value > 0, "Donation must be greater than 0");
        giveawayPool += msg.value;
        coupons[msg.sender] += 1;
        emit DonationReceived(msg.sender, msg.value);
    }

    // Function for owner to assign a winner
    function assignWinner(address _winner) external onlyOwner {
        winners[_winner] = true;
        emit WinnerAssigned(_winner);
    }

    // Function for the winner to claim their giveaway Ether
    function claimCoupon() external onlyWinner {
        uint256 amount = giveawayPool;
        giveawayPool = 0;
        winners[msg.sender] = false;
        payable(msg.sender).transfer(amount);
        emit CouponClaimed(msg.sender, amount);
    }

    // Public view function to check the current giveaway pool
    function getGiveawayPool() external view returns (uint256) {
        return giveawayPool;
    }
}
