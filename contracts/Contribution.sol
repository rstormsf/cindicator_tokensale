pragma solidity ^0.4.15;

import "./SafeMath.sol";
import "./MiniMeToken.sol";
import "./Tier.sol";
import "./CND.sol";

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
  bool public transferable = false;
  uint256 public October12_2017 = 1507830400;
  address public contributionWallet;
  address public foundersWallet;
  address public advisorsWallet;
  address public bountyWallet;
  bool public finalAllocation;

  uint256 public totalTokensSold;

  bool public paused = false;

  modifier notAllocated() {
    require(finalAllocation == false);
    _;
  }

  modifier endedSale() {
    require(tierCount == 4); //when last one finished it should be equal to 4
    _;
  }

  modifier tokenInitialized() {
    assert(address(cnd) != 0x0);
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

  modifier notPaused() {
    require(!paused);
    _;
  }

  function Contribution(address _contributionWallet, address _foundersWallet, address _advisorsWallet, address _bountyWallet) {
    require(_contributionWallet != 0x0);
    require(_foundersWallet != 0x0);
    require(_advisorsWallet != 0x0);
    require(_bountyWallet != 0x0);
    contributionWallet = _contributionWallet;
    foundersWallet = _foundersWallet;
    advisorsWallet =_advisorsWallet;
    bountyWallet = _bountyWallet;
    tierCount = 0;
  }

  function initializeToken(address _cnd) public onlyController {
    assert(CND(_cnd).controller() == address(this));
    assert(CND(_cnd).IS_CND_CONTRACT_MAGIC_NUMBER() == 0x1338);
    require(_cnd != 0x0);
    cnd = CND(_cnd);
  }

  function initializeTier(
    uint256 _tierNumber,
    address _tierAddress
  ) public onlyController tokenInitialized
  {
    Tier tier = Tier(_tierAddress);
    assert(tier.controller() == address(this));
    //cannot be more than 4 tiers
    require(_tierNumber >= 0 && _tierNumber <= 3);
    assert(tier.IS_TIER_CONTRACT_MAGIC_NUMBER() == 0x1337);
    // check if tier is not defined
    assert(tiers[_tierNumber] == address(0));
    tiers[_tierNumber] = tier;
    InitializedTier(_tierNumber, _tierAddress);
  }

  /// @notice If anybody sends Ether directly to this contract, consider the sender will
  /// be rejected.
  function () public {
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

   function buy() public payable {
     proxyPayment(msg.sender);
   }
// since we disable fallback functions, we have to have this param in order to satisfy TokenController inheritance
  function proxyPayment(address _sender) public payable 
    notPaused
    initialized
    returns (bool) 
  {
    _sender = msg.sender;
    assert(isCurrentTierCapReached() == false);
    assert(contributionOpen());
    require(isWhitelisted(msg.sender, tierCount));
    doBuy();
    return true;
  }

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @return False if the controller does not authorize the transfer
  function onTransfer(address /* _from */, address /* _to */, uint256 /* _amount */) returns(bool) {
    return (transferable || getBlockTimestamp() >= October12_2017 );
  } 

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @return False if the controller does not authorize the approval
  function onApprove(address /* _owner */, address /* _spender */, uint /* _amount */) returns(bool) {
    return (transferable || getBlockTimestamp() >= October12_2017);
  }

  function allowTransfers(bool _transferable) onlyController {
    transferable = _transferable;
  }

  function leftForSale() public constant returns(uint256) {
    Tier tier = tiers[tierCount];
    uint256 weiLeft = tier.cap().sub(tier.totalInvestedWei());
    uint256 tokensLeft = weiLeft.mul(tier.exchangeRate());
    return tokensLeft;
  }

  function doBuy() internal {
    Tier tier = tiers[tierCount];
    assert(msg.value >= tier.minInvestorCap() && msg.value <= tier.maxInvestorCap());
    address caller = msg.sender;
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

  function allocate() public notAllocated endedSale returns(bool) {
    finalAllocation = true;
    uint256 totalSupplyCDN = totalTokensSold.mul(100).div(75); // calculate 100%
    uint256 foundersAllocation = totalSupplyCDN.div(5); // 20% goes to founders
    assert(cnd.generateTokens(foundersWallet, foundersAllocation));
    
    uint256 advisorsAllocation = totalSupplyCDN.mul(38).div(1000); // 3.8% goes to advisors
    assert(cnd.generateTokens(advisorsWallet, advisorsAllocation));
    uint256 bountyAllocation = totalSupplyCDN.mul(12).div(1000); // 1.2% goes to  bounty program
    assert(cnd.generateTokens(bountyWallet, bountyAllocation));
    return true;
  }

  /// @notice This method will can be called by the controller before the contribution period
  ///  end or by anybody after the `endTime`. This method finalizes the contribution period
  ///  by creating the remaining tokens and transferring the controller to the configured
  ///  controller.
  function finalize() public initialized {
    Tier tier = tiers[tierCount];
    assert(tier.finalizedTime() == 0);
    assert(getBlockTimestamp() >= tier.startTime());
    assert(msg.sender == controller || getBlockTimestamp() > tier.endTime() || isCurrentTierCapReached());

    tier.finalize();
    tierCount++;

    FinalizedTier(tierCount, tier.finalizedTime());
  }

  function isCurrentTierCapReached() public constant returns(bool) {
    Tier tier = tiers[tierCount];
    return tier.isCapReached();
  }

  //////////
  // Testing specific methods
  //////////

  function getBlockTimestamp() internal constant returns (uint256) {
    return block.timestamp;
  }



  //////////
  // Safety Methods
  //////////

  /// @notice This method can be used by the controller to extract mistakenly
  ///  sent tokens to this contract.
  /// @param _token The address of the token contract that you want to recover
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address _token) public onlyController {
    if (cnd.controller() == address(this)) {
      cnd.claimTokens(_token);
    }

    if (_token == 0x0) {
      controller.transfer(this.balance);
      return;
    }

    CND token = CND(_token);
    uint256 balance = token.balanceOf(this);
    token.transfer(controller, balance);
    ClaimedTokens(_token, controller, balance);
  }

  /// @notice Pauses the contribution if there is any issue
  function pauseContribution(bool _paused) onlyController {
    paused = _paused;
  }

  event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
  event NewSale(address indexed _th, uint256 _amount, uint256 _tokens);
  event InitializedTier(uint256 _tierNumber, address _tierAddress);
  event FinalizedTier(uint256 _tierCount, uint256 _now);
  event Refund(uint256 _amount);
  
}
