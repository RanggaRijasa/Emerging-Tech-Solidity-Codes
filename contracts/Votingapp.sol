// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingContract {
    // Enum to represent election phases
    enum ElectionPhase { NotStarted, Open, Closed }
    ElectionPhase public electionPhase;

    // Structs for candidates and voters
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint votedCandidateId;
    }

    // State variables
    address public admin;
    uint public candidateCount;
    mapping(uint => Candidate) public candidates;
    mapping(address => Voter) public voters;

    // Events
    event CandidateAdded(uint candidateId, string candidateName);
    event VoterAdded(address voter);
    event VoteCast(address voter, uint candidateId);
    event VotingOpened();
    event VotingClosed();

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyDuringVoting() {
        require(electionPhase == ElectionPhase.Open, "Voting is not open");
        _;
    }

    modifier onlyOnce() {
        require(!voters[msg.sender].hasVoted, "You can only vote once");
        _;
    }

    constructor() {
        admin = msg.sender;
        electionPhase = ElectionPhase.NotStarted;
    }

    // Function to add a candidate, only accessible by the admin
    function addCandidate(string memory _name) public onlyAdmin {
        candidateCount++;
        candidates[candidateCount] = Candidate(candidateCount, _name, 0);
        emit CandidateAdded(candidateCount, _name);
    }

    // Function to add a voter, only accessible by the admin
    function addVoter(address _voter) public onlyAdmin {
        voters[_voter] = Voter(false, 0);
        emit VoterAdded(_voter);
    }

    // Function to open voting, only accessible by the admin
    function openVoting() public onlyAdmin {
        require(electionPhase == ElectionPhase.NotStarted, "Election is already started or closed");
        electionPhase = ElectionPhase.Open;
        emit VotingOpened();
    }

    // Function to close voting, only accessible by the admin
    function closeVoting() public onlyAdmin {
        require(electionPhase == ElectionPhase.Open, "Election is not open");
        electionPhase = ElectionPhase.Closed;
        emit VotingClosed();
    }

    // Function for authorized voters to cast a vote
    function vote(uint _candidateId) public onlyDuringVoting onlyOnce {
        require(voters[msg.sender].hasVoted == false, "Already voted");
        require(candidates[_candidateId].id != 0, "Invalid candidate");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;

        emit VoteCast(msg.sender, _candidateId);
    }

    // View function to get the vote count for a specific candidate
    function getCandidateVotes(uint _candidateId) public view returns (uint) {
        return candidates[_candidateId].voteCount;
    }

    // View function to get the current election status
    function getElectionStatus() public view returns (string memory) {
        if (electionPhase == ElectionPhase.NotStarted) return "Not Started";
        if (electionPhase == ElectionPhase.Open) return "Open";
        if (electionPhase == ElectionPhase.Closed) return "Closed";
        return "";
    }
}
