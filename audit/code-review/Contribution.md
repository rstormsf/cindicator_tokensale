# Contribution

Source file [../../contracts/Contribution.sol](../../contracts/Contribution.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.15;

// BK Next 4 Ok
import "./SafeMath.sol";
import "./MiniMeToken.sol";
import "./Tier.sol";
import "./CND.sol";

// BK Ok
contract Contribution is Controlled, TokenController {
  using SafeMath for uint256;

  struct WhitelistedInvestor {
      uint256 tier;
      bool status;
      uint256 contributedAmount;
  }

  mapping(address => WhitelistedInvestor) investors;
  Tier[4] public tiers;
  uint256 public tierCount;

  MiniMeToken public cnd;
  bool public transferable;
  address public contributionWallet;
  address public foundersWallet;
  address public advisorsWallet;
  address public bountyWallet;
  // BK Ok
  bool public finalAllocation;

  uint256 public totalTokensSold;                 // How much tokens have been sold

  // BK Ok
  bool public paused = false;

  // BK Ok
  modifier notAllocated() {
    // BK Ok
    require(finalAllocation == false);
    // BK Ok
    _;
  }

  // BK Ok
  modifier endedSale() {
    // BK Ok
    require(tierCount == 4); //when last one finished it should be equal to 4
    // BK Ok
    _;
  }

  modifier initialized() {
    Tier tier = tiers[tierCount];
    assert(tier.initializedTime() != 0);
    _;
  }

  function contributionOpen() public constant returns(bool) {
    Tier tier = tiers[tierCount];
    return (getBlockTimestamp() >= tier.startTime() && 
           getBlockTimestamp() <= tier.endTime() &&
           tier.finalizedTime() == 0);
  }

  // BK Ok
  modifier notPaused() {
    // BK Ok
    require(!paused);
    // BK Ok
    _;
  }

  function Contribution(address _cnd, address _contributionWallet, address _foundersWallet, address _advisorsWallet, address _bountyWallet) {
    require(_contributionWallet != 0x0);
    require(_foundersWallet != 0x0);
    require(_advisorsWallet != 0x0);
    require(_bountyWallet != 0x0);
    assert(CND(_cnd).IS_CND_CONTRACT_MAGIC_NUMBER() == 0x1338);
    require(_cnd != 0x0);
    contributionWallet = _contributionWallet;
    foundersWallet = _foundersWallet;
    advisorsWallet =_advisorsWallet;
    bountyWallet = _bountyWallet;
    cnd = CND(_cnd);
    tierCount = 0;
  }

  // BK Ok - Only controller can execute
  function initializeTier(
      uint256 _tierNumber,
      address _tierAddress
  ) public onlyController 
  {
    // BK Ok
    Tier tier = Tier(_tierAddress);
    // BK Ok
    assert(tier.controller() == address(this));
    //cannot be more than 4 tiers
    // BK Ok
    require(_tierNumber >= 0 && _tierNumber <= 3);
    // BK Ok
    assert(tier.IS_TIER_CONTRACT_MAGIC_NUMBER() == 0x1337);
    // check if tier is not defined
    // BK Ok
    assert(tiers[_tierNumber] == address(0));
    // BK Ok
    tiers[_tierNumber] = tier;
    // BK Ok - Log event
    InitializedTier(_tierNumber, _tierAddress);
  }

  /// @notice If anybody sends Ether directly to this contract, consider he is
  /// getting CND.
  // BK NOTE - Comment above is incorrect
  // BK Ok - Tx with ETH will be rejected
  function () public {
    // BK Ok
    require(false);
  }

  function investorAmountTokensToBuy(address _investor) public constant returns(uint256) {
       WhitelistedInvestor memory investor = investors[_investor];
       Tier tier = tiers[tierCount];


       uint256 leftToBuy = tier.maxInvestorCap().sub(investor.contributedAmount).mul(tier.exchangeRate());
       return leftToBuy;
  }

  function isWhitelisted(address _investor, uint256 _tier) public constant returns(bool) {
       WhitelistedInvestor memory investor = investors[_investor];
       return (investor.tier <= _tier && investor.status);
  }

  function whitelistAddresses(address[] _addresses, uint256 _tier, bool _status) public onlyController {
        for (uint256 i = 0; i < _addresses.length; i++) {
            address investorAddress = _addresses[i];
            require(investors[investorAddress].contributedAmount == 0);
            investors[investorAddress] = WhitelistedInvestor(_tier, _status, 0);
       }
   }
// since we disable fallback functions, we have to have this param in order to satisfy TokenController inheritance
  // BK Ok
  function proxyPayment(address _sender) public payable 
      notPaused
      initialized
      returns (bool) 
  {
    // BK CHECK - Normally the sender should not be overwritten
    _sender = msg.sender;
    // BK Ok
    assert(isCurrentTierCapReached() == false);
    // BK Ok
    assert(contributionOpen());
    // BK Ok
    require(isWhitelisted(msg.sender, tierCount));
    // BK Ok
    doBuy();
    // BK Ok
    return true;
  }


    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    // BK Ok
    function onTransfer(address _from, address _to, uint256 _amount) returns(bool) {
      // BK CHECK - The following line will generate a lot of additional event logs
      Log(_from, _to, _amount);
      return transferable;
    } 

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    // BK Ok
    function onApprove(address _owner, address _spender, uint _amount) returns(bool) {
      // BK CHECK - The following line will generate a lot of additional event logs
      Log(_owner, _spender, _amount);
      // BK Ok
      return transferable;
    }


  // BK NOTE - The controller can suspend and resume token transfers anytime
  // BK Ok - Only the controller can execute this
  function allowTransfers(bool _transferable) onlyController {
    // BK Ok
    transferable = _transferable;
    // BK Ok
    cnd.enableTransfers(_transferable);
  }

  // BK Ok - Constant function
  function leftForSale() public constant returns(uint256) {
    // BK Ok
    Tier tier = tiers[tierCount];
    // BK Ok
    uint256 weiLeft = tier.cap().sub(tier.totalInvestedWei());
    // BK Ok
    uint256 tokensLeft = weiLeft.mul(tier.exchangeRate());
    // BK Ok
    return tokensLeft;
  }

  // BK CHECK - What happens when tierCount = 4
  // BK Ok - Internal so cannot be called directly
  function doBuy() internal {
    Tier tier = tiers[tierCount];
    assert(msg.value >= tier.minInvestorCap() && msg.value <= tier.maxInvestorCap());
    // Antispam mechanism
    address caller;
    caller = msg.sender;
    assert(!isContract(caller));
    WhitelistedInvestor storage investor = investors[caller];
    uint256 investorTokenBP = investorAmountTokensToBuy(caller);

    require(investorTokenBP > 0);

    uint256 toFund = msg.value;  

    uint256 tokensGenerated = toFund.mul(tier.exchangeRate());

    uint256 tokensleftForSale = leftForSale();    

    if(tokensleftForSale > investorTokenBP ) {
        if(tokensGenerated > investorTokenBP) {
          tokensGenerated = investorTokenBP;
          toFund = investorTokenBP.div(tier.exchangeRate());
        }
    }

    if(investorTokenBP > tokensleftForSale) {
      if(tokensGenerated > tokensleftForSale) {
        tokensGenerated = tokensleftForSale;
        toFund = tokensleftForSale.div(tier.exchangeRate());
      }

    }

    investor.contributedAmount = investor.contributedAmount.add(toFund);
    tier.increaseInvestedWei(toFund);
    if (tokensGenerated == tokensleftForSale) {
      tier.finalize();
    }
    
    assert(cnd.generateTokens(caller, tokensGenerated));
    totalTokensSold = totalTokensSold.add(tokensGenerated);

    contributionWallet.transfer(toFund);
    NewSale(caller, toFund, tokensGenerated);
    uint256 toReturn = msg.value.sub(toFund);
    if (toReturn > 0) {
      caller.transfer(toReturn);
      Refund(toReturn);
    }
  }
  // BK Ok - Anyone can call
  function allocate() public notAllocated endedSale returns(bool) {
    // BK Ok
    finalAllocation = true;
    // BK Ok
    uint256 totalSupplyCDN = totalTokensSold.mul(100).div(75); // calculate 100%
    // BK Ok
    uint256 foundersAllocation = totalSupplyCDN.div(5); // 20% goes to founders
    // BK Ok
    assert(cnd.generateTokens(foundersWallet, foundersAllocation));
    
    // BK Ok
    uint256 advisorsAllocation = totalSupplyCDN.mul(38).div(1000); // 3.8% goes to advisors
    // BK Ok
    assert(cnd.generateTokens(advisorsWallet, advisorsAllocation));
    // BK Ok
    uint256 bountyAllocation = totalSupplyCDN.mul(12).div(1000); // 1.2% goes to  bounty program
    // BK Ok
    assert(cnd.generateTokens(bountyWallet, bountyAllocation));
    // BK Ok
    return true;

  }
  /// @dev Internal function to determine if an address is a contract
  /// @param _addr The address being queried
  /// @return True if `_addr` is a contract
  // BK Ok
  function isContract(address _addr) constant internal returns (bool) {
    // BK Ok
    if (_addr == 0) return false;
    // BK Ok
    uint256 size;
    // BK Ok
    assembly {
      // BK Ok
      size := extcodesize(_addr)
    }
    // BK Ok
    return (size > 0);
  }

  /// @notice This method will can be called by the controller before the contribution period
  ///  end or by anybody after the `endTime`. This method finalizes the contribution period
  ///  by creating the remaining tokens and transferring the controller to the configured
  ///  controller.
  // BK NOTE - Each tier has to be finalised
  function finalize() public initialized {
    // BK Ok
    Tier tier = tiers[tierCount];
    // BK Ok - Current tier not finalised yet 
    assert(tier.finalizedTime() == 0);
    // BK Ok - Can only finalise after the tier starting period
    assert(getBlockTimestamp() >= tier.startTime());
    // BK NOTE - Controller can execute this function anytime after the tier starting period, or
    // BK NOTE - anyone can call this if we are now past the tier end time or the tier cap has been reached
    // BK Ok
    assert(msg.sender == controller || getBlockTimestamp() > tier.endTime() || isCurrentTierCapReached());

    // BK Ok
    tier.finalize();
    // BK Ok - Move to the next tier
    tierCount++;

    // BK Ok - Log event
    FinalizedTier(tierCount, tier.finalizedTime());
  }

  // BK Ok
  function isCurrentTierCapReached() public constant returns(bool) {
    // BK Ok
    Tier tier = tiers[tierCount];
    // BK Ok
    return tier.isCapReached();
  }

  //////////
  // Testing specific methods
  //////////

  // BK Ok
  function getBlockTimestamp() internal constant returns (uint256) {
    // BK Ok
    return block.timestamp;
  }



  //////////
  // Safety Methods
  //////////

  /// @notice This method can be used by the controller to extract mistakenly
  ///  sent tokens to this contract.
  /// @param _token The address of the token contract that you want to recover
  ///  set to 0 in case you want to extract ether.
  // BK Ok
  function claimTokens(address _token) public onlyController {
    // BK Ok
    if (cnd.controller() == address(this)) {
      // BK Ok
      cnd.claimTokens(_token);
    }

    // BK Ok - Claim ETH
    if (_token == 0x0) {
      // BK Ok
      controller.transfer(this.balance);
      // BK Ok
      return;
    }

    // BK Ok
    CND token = CND(_token);
    // BK Ok
    uint256 balance = token.balanceOf(this);
    // BK Ok
    token.transfer(controller, balance);
    // BK Ok - Log event
    ClaimedTokens(_token, controller, balance);
  }

  /// @notice Pauses the contribution if there is any issue
  // BK Ok
  function pauseContribution(bool _paused) onlyController {
    // BK Ok
    paused = _paused;
  }

  // BK Next 6 Ok
  event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
  event NewSale(address indexed _th, uint256 _amount, uint256 _tokens);
  event Log(address _one, address _two, uint256 _three);
  event InitializedTier(uint256 _tierNumber, address _tierAddress);
  event FinalizedTier(uint256 _tierCount, uint256 _now);
  event Refund(uint256 _amount);
  
}

```
