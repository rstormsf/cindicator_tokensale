# Tier

Source file [../../contracts/Tier.sol](../../contracts/Tier.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.15;
// BK Next 2 Ok
import "./SafeMath.sol";
import "./MiniMeToken.sol";

// BK Ok
contract Tier is Controlled {
  // BK Ok
  using SafeMath for uint256;
  // BK Next 9 Ok
  uint256 public cap;
  uint256 public exchangeRate;
  uint256 public minInvestorCap;
  uint256 public maxInvestorCap;
  uint256 public startTime;
  uint256 public endTime;
  uint256 public initializedTime;
  uint256 public finalizedTime;
  uint256 public totalInvestedWei;
  // BK Ok
  uint256 public constant IS_TIER_CONTRACT_MAGIC_NUMBER = 0x1337;

  // BK Ok
  modifier notFinished() {
    // BK Ok
    require(finalizedTime == 0);
    // BK Ok
    _;
  }

    // BK Ok - Only controller can execute
  function Tier(
    uint256 _cap,
    uint256 _minInvestorCap,
    uint256 _maxInvestorCap,
    uint256 _exchangeRate,
    uint256 _startTime,
    uint256 _endTime
  )
  {
    // BK Ok
    require(initializedTime == 0);
    // BK Ok - Start in the future
    assert(_startTime >= getBlockTimestamp());
    // BK Ok - Start before End
    require(_startTime < _endTime);
    // BK Next 2 Ok
    startTime = _startTime;
    endTime = _endTime;

    // BK Ok
    require(_cap > 0);
    // BK Ok
    require(_cap > _maxInvestorCap);
    // BK Ok
    cap = _cap;

    // BK Ok - min < max, max > 0
    require(_minInvestorCap < _maxInvestorCap && _maxInvestorCap > 0);
    // BK Next 2 Ok
    minInvestorCap = _minInvestorCap;
    maxInvestorCap = _maxInvestorCap;

    // BK Ok
    require(_exchangeRate > 0);
    // BK Ok
    exchangeRate = _exchangeRate;

    // BK Ok
    initializedTime = getBlockTimestamp();
    // BK Ok - Log event
    InitializedTier(_cap, _minInvestorCap, maxInvestorCap, _startTime, _endTime);
  }

  // BK Ok
  function getBlockTimestamp() internal constant returns (uint256) {
    // BK Ok
    return block.timestamp;
  }

  // BK Ok
  function isCapReached() public constant returns(bool) {
    // BK Ok
    return totalInvestedWei == cap;
  }

  // BK NOTE - Anyone can call this is the cap is reached or we are past the crowdsale end date, or the controller calls this
  // BK Ok
  function finalize() public {
    // BK Ok
    require(finalizedTime == 0);
    // BK Ok
    uint256 currentTime = getBlockTimestamp();
    // BK Ok
    assert(cap == totalInvestedWei || currentTime > endTime || msg.sender == controller);
    // BK Ok
    finalizedTime = currentTime;
  }

  // BK Ok - Only controller can call when not finalised
  function increaseInvestedWei(uint256 _wei) external onlyController notFinished {
    // BK Ok - Add new amount
    totalInvestedWei = totalInvestedWei.add(_wei);
    // BK Ok - Log event - after change
    IncreaseInvestedWeiAmount(_wei, totalInvestedWei);
  }

  // BK Ok
  event InitializedTier(
   uint256 _cap,
   uint256 _minInvestorCap, 
   uint256 _maxInvestorCap, 
   uint256 _startTime,
   uint256 _endTime
  );

  // BK Ok - Don't accept ETH contribution
  function () public {
    require(false);
  }
  // BK Ok
  event IncreaseInvestedWeiAmount(uint256 _amount, uint256 _newWei);
}
```
