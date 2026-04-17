// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Voting {
    // --- State Variables ---
    address public owner;
    bool public votingOpen;
    uint public votingDeadline;

    bytes32[] public candidateList;

    mapping(bytes32 => uint) public votesReceived;
    mapping(address => bool) public hasVoted;
    mapping(bytes32 => bool) private validCandidate;

    // --- Events ---
    event VoteCast(address indexed voter, bytes32 indexed candidate);
    event VotingStarted(uint deadline);
    event VotingClosed();

    // --- Modifiers ---
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier isVotingOpen() {
        require(votingOpen, "Voting is not open");
        require(block.timestamp < votingDeadline, "Voting deadline passed");
        _;
    }

    // --- Constructor ---
    constructor(bytes32[] memory candidates, uint durationMinutes) {
        owner = msg.sender;
        votingOpen = true;
        votingDeadline = block.timestamp + (durationMinutes * 1 minutes);

        for (uint i = 0; i < candidates.length; i++) {
            candidateList.push(candidates[i]);
            validCandidate[candidates[i]] = true;
        }

        emit VotingStarted(votingDeadline);
    }

    // --- Core Functions ---
    function vote(bytes32 candidate) public isVotingOpen {
        require(validCandidate[candidate], "Not a valid candidate");
        require(!hasVoted[msg.sender], "You have already voted");

        hasVoted[msg.sender] = true;
        votesReceived[candidate]++;

        emit VoteCast(msg.sender, candidate);
    }

    function getVotes(bytes32 candidate) public view returns (uint) {
        require(validCandidate[candidate], "Not a valid candidate");
        return votesReceived[candidate];
    }

    function getCandidates() public view returns (bytes32[] memory) {
        return candidateList;
    }

    function closeVoting() public onlyOwner {
        votingOpen = false;
        emit VotingClosed();
    }

    function getWinner() public view returns (bytes32 winner) {
        uint winningVoteCount = 0;
        for (uint i = 0; i < candidateList.length; i++) {
            if (votesReceived[candidateList[i]] > winningVoteCount) {
                winningVoteCount = votesReceived[candidateList[i]];
                winner = candidateList[i];
            }
        }
    }
}