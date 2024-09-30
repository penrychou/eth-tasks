// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Ballot {
    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    struct Voter {
        uint256 weight;
        uint256 untilTime;
        bool voteRighted;
    }

    uint256 public startTime;
    uint256 public endTime;

    address public chairperson;

    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    mapping(address => uint) public votedProposal;

    modifier onlyDuringVoting() {
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "Voting is not in progress"
        );
        _;
    }

    modifier onlyOwner() {
        require(
            msg.sender == chairperson,
            "Only the chairperson can call this function"
        );
        _;
    }

    // Constructor initializes the contract with a chairperson and empty proposals.
    constructor(
        uint256 _startTime,
        uint256 _endTime,
        bytes32[] memory proposalNames,
        address chairpersonAddress
    ) {
        require(
            _startTime >= block.timestamp,
            "startTime must be in the future"
        );
        require(
            _endTime >= _startTime,
            "endTime must be greater than startTime"
        );

        chairperson = chairpersonAddress;
        voters[chairperson].voteRighted = true; // The chairperson is allowed to vote.
        voters[chairperson].weight = 1;

        startTime = _startTime;
        endTime = _endTime;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
    }

    function giveRightToVote(address voter) public onlyOwner {
        require(
            voters[voter].voteRighted == false,
            "The voter already has the right to vote."
        );
        voters[voter] = Voter({
            weight: 1,
            untilTime: block.timestamp,
            voteRighted: true
        });
    }

    function vote(uint proposal) public onlyDuringVoting {
        require(
            voters[msg.sender].voteRighted,
            "You must have voting rights to vote."
        );
        require(votedProposal[msg.sender] == 0, "You have already voted.");
        votedProposal[msg.sender] = proposal + 1;
        proposals[proposal].voteCount += voters[msg.sender].weight;
    }

    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function setVoterWeight(
        address voter,
        uint256 weight,
        uint256 untilTime
    ) external onlyDuringVoting onlyOwner {
        require(weight > 0, "Weight must be greater than 0.");

        Voter storage v = voters[voter];
        v.weight = weight;
        v.untilTime = untilTime;
    }
}
