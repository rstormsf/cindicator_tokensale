pragma solidity ^0.4.15;

import "./Contribution.sol";

contract DebugContribution is Contribution {
    uint256 public timeStamp = now;
  function setBlockTimestamp(uint256 _timeStamp) public onlyController {
    timeStamp = _timeStamp;
  }

  function getBlockTimestamp() internal constant returns (uint256) {
      if (timeStamp > block.timestamp) {
        return timeStamp;
      } else {
        return block.timestamp;
      }
  }
  
  function DebugContribution(address _cnd, address _contributionWallet, address _foundersWallet, address _advisorsWallet, address _bountyWallet) 
    Contribution(_cnd, _contributionWallet, _foundersWallet, _advisorsWallet, _bountyWallet)
  {
  }

}
