pragma solidity ^0.4.15;
import "./SafeMath.sol";
import "./MiniMeToken.sol";

contract Tier is Controlled {
  using SafeMath for uint256;
  uint256 public cap;
  uint256 public exchangeRate;
  uint256 public minInvestorCap;
  uint256 public maxInvestorCap;
  uint256 public startTime;
  uint256 public endTime;
  uint256 public initializedTime;
  uint256 public finalizedTime;
  uint256 public totalInvestedWei;
  uint256 public constant IS_TIER_CONTRACT_MAGIC_NUMBER = 0x1337;

  modifier notFinished() {
    require(finalizedTime == 0);
    _;
  }

  function Tier(
    uint256 _cap,
    uint256 _minInvestorCap,
    uint256 _maxInvestorCap,
    uint256 _exchangeRate,
    uint256 _startTime,
    uint256 _endTime
  )
  {
    require(initializedTime == 0);
    assert(_startTime >= getBlockTimestamp());
    require(_startTime < _endTime);
    startTime = _startTime;
    endTime = _endTime;

    require(_cap > 0);
    require(_cap > _maxInvestorCap);
    cap = _cap;

    require(_minInvestorCap < _maxInvestorCap && _maxInvestorCap > 0);
    minInvestorCap = _minInvestorCap;
    maxInvestorCap = _maxInvestorCap;

    require(_exchangeRate > 0);
    exchangeRate = _exchangeRate;

    initializedTime = getBlockTimestamp();
    InitializedTier(_cap, _minInvestorCap, maxInvestorCap, _startTime, _endTime);
  }

  function getBlockTimestamp() internal constant returns (uint256) {
    return block.timestamp;
  }

  function isCapReached() public constant returns(bool) {
    return totalInvestedWei == cap;
  }

  function finalize() public {
    require(finalizedTime == 0);
    uint256 currentTime = getBlockTimestamp();
    assert(cap == totalInvestedWei || currentTime > endTime || msg.sender == controller);
    finalizedTime = currentTime;
  }

  function increaseInvestedWei(uint256 _wei) external onlyController notFinished {
    totalInvestedWei = totalInvestedWei.add(_wei);
    IncreaseInvestedWeiAmount(_wei, totalInvestedWei);
  }

  event InitializedTier(
   uint256 _cap,
   uint256 _minInvestorCap, 
   uint256 _maxInvestorCap, 
   uint256 _startTime,
   uint256 _endTime
  );

  function () public {
    require(false);
  }
  event IncreaseInvestedWeiAmount(uint256 _amount, uint256 _newWei);
}