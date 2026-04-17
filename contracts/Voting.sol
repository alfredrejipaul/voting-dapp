// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Decentralised Voting Contract
/// @author Alfred Reji
/// @notice On-chain voting with deadline enforcement and access control
contract Voting {

    address public owner;
    bool public votingOpen;
    uint256 public votingDeadline;
    bytes32[] public candidateList;

    mapping(bytes32 => uint256) public votesReceived;
    mapping(address => bool) public hasVoted;
    mapping(bytes32 => bool) private validCandidate;

    error NotOwner();
    error VotingNotOpen();
    error DeadlinePassed();
    error InvalidCandidate();
    error AlreadyVoted();

    event VoteCast(address indexed voter, bytes32 indexed candidate);
    event VotingStarted(uint256 indexed deadline);
    event VotingClosed();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier isVotingOpen() {
        if (!votingOpen) revert VotingNotOpen();
        if (block.timestamp >= votingDeadline) revert DeadlinePassed();
        _;
    }

    /// @notice Deploys the contract and initialises candidates
    /// @param candidates Array of candidate names as bytes32
    /// @param durationMinutes How long voting stays open in minutes
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

    /// @notice Cast a vote for a candidate
    /// @param candidate The bytes32 name of the candidate
    function vote(bytes32 candidate) public isVotingOpen {
        if (!validCandidate[candidate]) revert InvalidCandidate();
        if (hasVoted[msg.sender]) revert AlreadyVoted();

        hasVoted[msg.sender] = true;
        ++votesReceived[candidate];

        emit VoteCast(msg.sender, candidate);
    }

    /// @notice Get the vote count for a candidate
    /// @param candidate The bytes32 name of the candidate
    /// @return The number of votes received
    function getVotes(bytes32 candidate) public view returns (uint256) {
        if (!validCandidate[candidate]) revert InvalidCandidate();
        return votesReceived[candidate];
    }

    /// @notice Returns the full list of candidates
    function getCandidates() public view returns (bytes32[] memory) {
        return candidateList;
    }

    /// @notice Closes voting, only callable by owner
    function closeVoting() public onlyOwner {
        votingOpen = false;
        emit VotingClosed();
    }

    /// @notice Returns the candidate with the most votes
    /// @return winner The bytes32 name of the winning candidate
    function getWinner() public view returns (bytes32 winner) {
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < candidateList.length; ++i) {
            if (votesReceived[candidateList[i]] >= winningVoteCount + 1) {
                winningVoteCount = votesReceived[candidateList[i]];
                winner = candidateList[i];
            }
        }
    }
}