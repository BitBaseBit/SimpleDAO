pragma solidity ^0.7.3;

import '@openzeppelin/contracs/token/ERC20/ERC20.sol';

contract DAO {
  enum Side { Yes, No }
  enum Status {Undecided, Approved, Rejected }

  struct Proposal {
    address author;
    bytes32 hash;
    uint    createdAt;
    uint    votesYes;
    uint    votesNo;
    Status  status;
  }

  mapping(bytes32 => Proposal)                 public proposals;
  mapping(address => mapping(bytes32 => bool)) public hasVoted;
  mapping(address => uint)                     public shares;
  uint                                         public totalShares;
  IERC20                                       public token;

  uint constant CRATE_PROP_MIN_SHARE = 1000 *  10 ** 18;
  uint constant VOTING_PERIOD        = 7 days;

  constructor(address _token) {
    token = IERC20(_token);
  }

  function deposit(uint amount) external {
    shares[msg.sender] += amount;
    totalShares        += amount;
    token.transferFrom(msg.sender, address(this), amount);
  }

  function withdraw(uint amount) external {
    require(shares[msg.sender] >= amount, "Withdrawal amount larger than deposited balance");
    shares[msg.sender] -= amount;
    totalShares        -= amount;
    token.transfer(msg.sender, amount);
  }

  function createProposal(bytes32 propHash) external {
    require(
      shares[msg.sender] >= CRATE_PROP_MIN_SHARE,
      "You do not have enough shares to crate a proposal"
    );
    require(proposals[propHash].hash == bytes32(0));
    proposals[propHash] = Proposal(
      msg.sender,
      block.timestamp,
      0,
      0,
      Status.Undecided;
    );

  }
}
