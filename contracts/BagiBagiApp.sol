// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BagiBagi {
    address public owner;
    uint public couponCounter = 0;

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // Modifier to check if the sender is a winner
    modifier onlyWinner(uint _couponId) {
        require(coupons[_couponId].winner == msg.sender, "You are not the winner");
        _;
    }

    // Event to emit when a new donation is made
    event DonationReceived(address indexed donor, uint amount, uint couponId);
    
    // Event to emit when a winner is assigned
    event WinnerAssigned(uint couponId, address indexed winner);

    // Mapping to store donations and coupons
    mapping(uint => Coupon) public coupons;

    // Coupon structure
    struct Coupon {
        address donor;
        uint amount;
        address winner;
        bool claimed;
    }

    constructor() {
        owner = msg.sender;
    }

    // Public function to donate Ether and create a giveaway coupon
    function donate() external payable {
        require(msg.value > 0, "Donation amount must be greater than zero");

        // Create a new coupon with the donation
        coupons[couponCounter] = Coupon({
            donor: msg.sender,
            amount: msg.value,
            winner: address(0),
            claimed: false
        });

        emit DonationReceived(msg.sender, msg.value, couponCounter);
        couponCounter++;
    }

    // Owner assigns a winner to a specific coupon
    function assignWinner(uint _couponId, address _winner) external onlyOwner {
        require(_couponId < couponCounter, "Invalid coupon ID");
        require(coupons[_couponId].winner == address(0), "Winner already assigned");

        coupons[_couponId].winner = _winner;
        emit WinnerAssigned(_couponId, _winner);
    }

    // Function for the winner to claim their Ether prize
    function claimCoupon(uint _couponId) external onlyWinner(_couponId) {
        require(_couponId < couponCounter, "Invalid coupon ID");
        require(!coupons[_couponId].claimed, "Coupon already claimed");
        
        uint amount = coupons[_couponId].amount;
        coupons[_couponId].claimed = true;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    // Public view function to get coupon details
    function getCouponDetails(uint _couponId) external view returns (address, uint, address, bool) {
        require(_couponId < couponCounter, "Invalid coupon ID");
        Coupon memory coupon = coupons[_couponId];
        return (coupon.donor, coupon.amount, coupon.winner, coupon.claimed);
    }
}
