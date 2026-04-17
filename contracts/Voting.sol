// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Decentralised Voting Contract
/// @author Alfred Reji
/// @notice Allows users to vote for candidates on-chain with deadline and access control
contract Voting {

    // --- State Variables ---
    /// @notice Address of the contract deployer
    address public owner;

    /// @notice Whether voting is currently open
    bool public votingOpen;

    /// @notice Unix timestamp when voting closes
    uint256 public votingDeadline;

    /// @notice List of candidate names as bytes32
    bytes32[] public candidateList;

    /// @notice Maps candidate name to vote count
    mapping(bytes32 => uint256) public votesReceived;

    /// @notice Maps address to whether they have voted
    mapping(address => bool) public hasVoted;

    /// @notice Maps candidate name to whether it is valid
    mapping(bytes32 => bool) private validCandidate;

    // --- Events ---
    /// @notice Emitted when a vote is cast
    /// @param voter The address that voted
    /// @param candidate The candidate voted for
    event VoteCast(address indexed voter, bytes32 indexed candidate);

    /// @notice Emitted when voting begins
    /// @param deadline The timestamp when voting closes
    event VotingStarted(uint256 indexed deadline);

    /// @notice Emitted when voting is closed by owner
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
    /// @notice Deploys the contract and initialises candidates
    /// @param candidates Array of candidate names as bytes32
    /// @param durationMinutes How long voting stays open
    constructor(bytes32[] memory candidates, uint256 durationMinutes) {
        owner = msg.sender;
        votingOpen = true;
        votingDeadline = block.timestamp + (durationMinutes * 1 minutes);

        for (uint256 i = 0; i < candidates.length; ++i) {
            candidateList.push(candidates[i]);
            validCandidate[candidates[i]] = true;
        }

        emit VotingStarted(votingDeadline);
    }

    // --- Core Functions ---
    /// @notice Cast a vote for a candidate
    /// @param candidate The bytes32 name of the candidate
    function vote(bytes32 candidate) public isVotingOpen {
        require(validCandidate[candidate], "Not a valid candidate");
        require(!hasVoted[msg.sender], "You have already voted");

        hasVoted[msg.sender] = true;
        ++votesReceived[candidate];

        emit VoteCast(msg.sender, candidate);
    }

    /// @notice Get the vote count for a candidate
    /// @param candidate The bytes32 name of the candidate
    /// @return The number of votes received
    function getVotes(bytes32 candidate) public view returns (uint256) {
        require(validCandidate[candidate], "Not a valid candidate");
        return votesReceived[candidate];
    }

    /// @notice Returns the full list of candidates
    function getCandidates() public view returns (bytes32[] memory) {
        return candidateList;
    }

    /// @notice Closes voting — only callable by owner
    function closeVoting() public onlyOwner {
        votingOpen = false;
        emit VotingClosed();
    }

    /// @notice Returns the candidate with the most votes
    /// @return winner The bytes32 name of the winning candidate
    function getWinner() public view returns (bytes32 winner) {
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < candidateList.length; ++i) {
            if (votesReceived[candidateList[i]] > winningVoteCount) {
                winningVoteCount = votesReceived[candidateList[i]];
                winner = candidateList[i];
            }
        }
    }
}