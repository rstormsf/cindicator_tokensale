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
  // BK Ok
  using SafeMath for uint256;

  // BK Next block Ok
  struct WhitelistedInvestor {
    uint256 tier;
    bool status;
    uint256 contributedAmount;
  }

  // BK Ok
  mapping(address => WhitelistedInvestor) investors;
  // BK Ok
  Tier[4] public tiers;
  // BK Ok
  uint256 public tierCount;

  // BK Ok
  MiniMeToken public cnd;
  // BK Ok
  bool public transferable = false;
  // BK Ok
  uint256 public October12_2017 = 1507830400;
  // BK Next 4 Ok
  address public contributionWallet;
  address public foundersWallet;
  address public advisorsWallet;
  address public bountyWallet;
  // BK Ok
  bool public finalAllocation;

  // BK Ok
  uint256 public totalTokensSold;

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

  modifier tokenInitialized() {
    assert(address(cnd) != 0x0);
    _;
  }

  // BK Ok
  modifier initialized() {
    // BK Ok
    Tier tier = tiers[tierCount];
    // BK Ok
    assert(tier.initializedTime() != 0);
    // BK Ok
    _;
  }
  /// @notice Provides information if contribution is open
  /// @return False if the contribuion is closed
  // BK Ok
  function contributionOpen() public constant returns(bool) {
    // BK Ok
    Tier tier = tiers[tierCount];
    // BK Ok
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

  // BK Ok - Constructor
  function Contribution(address _contributionWallet, address _foundersWallet, address _advisorsWallet, address _bountyWallet) {
    // BK Next 4 Ok
    require(_contributionWallet != 0x0);
    require(_foundersWallet != 0x0);
    require(_advisorsWallet != 0x0);
    require(_bountyWallet != 0x0);
    // BK Next 4 Ok
    contributionWallet = _contributionWallet;
    foundersWallet = _foundersWallet;
    advisorsWallet =_advisorsWallet;
    bountyWallet = _bountyWallet;
    // BK Ok
    tierCount = 0;
  }
  /// @notice Initializes CND token to contribution
  /// @param _cnd The address of the token contract that you want to set
  function initializeToken(address _cnd) public onlyController {
    assert(CND(_cnd).controller() == address(this));
    assert(CND(_cnd).IS_CND_CONTRACT_MAGIC_NUMBER() == 0x1338);
    require(_cnd != 0x0);
    cnd = CND(_cnd);
  }
  /// @notice Initializes Tier contribution
  /// @param _tierNumber number of tier to initialize
  /// @param _tierAddress address of deployed tier
  // BK Ok - Only controller can execute
  function initializeTier(
    uint256 _tierNumber,
    address _tierAddress
  ) public onlyController tokenInitialized
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

  /// @notice If anybody sends Ether directly to this contract, consider the sender will
  /// be rejected.
  // BK NOTE - Comment above is incorrect
  // BK Ok - Tx with ETH will be rejected
  function () public {
    // BK Ok
    require(false);
  }
  /// @notice Amount of tokens an investor can purchase
  /// @param _investor investor address
  /// @return number of tokens  
  // BK Ok - Constant function
  function investorAmountTokensToBuy(address _investor) public constant returns(uint256) {
    // BK Ok
    WhitelistedInvestor memory investor = investors[_investor];
    // BK Ok
    Tier tier = tiers[tierCount];

    // BK Ok
    uint256 leftToBuy = tier.maxInvestorCap().sub(investor.contributedAmount).mul(tier.exchangeRate());
    // BK Ok
    return leftToBuy;
  }
  /// @notice Notifies if an investor is whitelisted for contribution
  /// @param _investor investor address
  /// @param _tier tier Number
  /// @return number of tokens 
  // BK Ok - Constant function
  function isWhitelisted(address _investor, uint256 _tier) public constant returns(bool) {
    // BK Ok
    WhitelistedInvestor memory investor = investors[_investor];
    // BK Ok
    return (investor.tier <= _tier && investor.status);
  }
  /// @notice interface for founders to whitelist investors
  /// @param _addresses array of investors
  /// @param _tier tier Number
  /// @param _status enable or disable
  // BK Ok - Only controller can execute to add whitelisted addresses
  function whitelistAddresses(address[] _addresses, uint256 _tier, bool _status) public onlyController {
    // BK Ok
    for (uint256 i = 0; i < _addresses.length; i++) {
        // BK Ok
        address investorAddress = _addresses[i];
        // BK Ok
        require(investors[investorAddress].contributedAmount == 0);
        // BK Ok
        investors[investorAddress] = WhitelistedInvestor(_tier, _status, 0);
    }
   }
  /// @notice Public function to buy tokens
   function buy() public payable {
     proxyPayment(msg.sender);
   }

  /// use buy function instead of proxyPayment
  /// the param address is useless, it always reassigns to msg.sender
  // BK NOTE - Normally this function allows the sending account to pay ETH to buy
  // BK NOTE - tokens on behalf of the address specified in the parameter
  // BK Ok
  function proxyPayment(address) public payable 
    notPaused
    initialized
    returns (bool) 
  {
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
  /// @return False if the controller does not authorize the transfer
  // BK Ok
  function onTransfer(address /* _from */, address /* _to */, uint256 /* _amount */) returns(bool) {
    // BK Ok
    return (transferable || getBlockTimestamp() >= October12_2017 );
  } 

  /// @notice Notifies the controller about an approval allowing the
  ///  controller to react if desired
  /// @return False if the controller does not authorize the approval
  // BK Ok
  function onApprove(address /* _owner */, address /* _spender */, uint /* _amount */) returns(bool) {
    // BK Ok
    return (transferable || getBlockTimestamp() >= October12_2017);
  }
  /// @notice Allows founders to set transfers before October12_2017
  /// @param _transferable set True if founders want to let people make transfers
  // BK Ok - Only the controller can execute this
  function allowTransfers(bool _transferable) onlyController {
    // BK Ok
    transferable = _transferable;
  }
  /// @notice calculates how many tokens left for sale
  /// @return Number of tokens left for tier
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
  /// @notice actual method that funds investor and contribution wallet
  // BK Ok - Internal so cannot be called directly
  function doBuy() internal {
    // BK Ok
    Tier tier = tiers[tierCount];
    // BK Ok
    assert(msg.value <= tier.maxInvestorCap());
    // BK Ok
    address caller = msg.sender;
    // BK Ok
    WhitelistedInvestor storage investor = investors[caller];
    // BK Ok
    uint256 investorTokenBP = investorAmountTokensToBuy(caller);
    // BK Ok
    require(investorTokenBP > 0);

    if(investor.contributedAmount == 0) {
      assert(msg.value >= tier.minInvestorCap());  
    }

    // BK Ok
    uint256 toFund = msg.value;  
    // BK Ok  
    uint256 tokensGenerated = toFund.mul(tier.exchangeRate());
    // check that at least 1 token will be generated
    require(tokensGenerated >= 1);
    // BK Ok
    uint256 tokensleftForSale = leftForSale();    

    // BK Ok
    if(tokensleftForSale > investorTokenBP ) {
      // BK Ok
      if(tokensGenerated > investorTokenBP) {
        // BK Ok
        tokensGenerated = investorTokenBP;
        // BK Ok
        toFund = investorTokenBP.div(tier.exchangeRate());
      }
    }

    // BK Ok
    if(investorTokenBP > tokensleftForSale) {
      // BK Ok
      if(tokensGenerated > tokensleftForSale) {
        // BK Ok
        tokensGenerated = tokensleftForSale;
        // BK Ok
        toFund = tokensleftForSale.div(tier.exchangeRate());
      }
    }

    // BK Ok
    investor.contributedAmount = investor.contributedAmount.add(toFund);
    // BK Ok
    tier.increaseInvestedWei(toFund);
    // BK Ok
    if (tokensGenerated == tokensleftForSale) {
      // BK Ok - Automatic tier finalisation
      finalize();
    }
    
    // BK Ok
    assert(cnd.generateTokens(caller, tokensGenerated));
    // BK Ok
    totalTokensSold = totalTokensSold.add(tokensGenerated);

    // BK Ok
    contributionWallet.transfer(toFund);

    // BK Ok
    NewSale(caller, toFund, tokensGenerated);

    // BK Ok
    uint256 toReturn = msg.value.sub(toFund);
    // BK Ok
    if (toReturn > 0) {
      // BK Ok
      caller.transfer(toReturn);
      // BK Ok
      Refund(toReturn);
    }
  }

  /// @notice This method will can be called by the anybody to make final allocation
  /// @return result if everything went succesfully
  // BK Ok - Anyone can call when tiers finalised
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

  /// @notice This method will can be called by the controller after the contribution period
  ///  end or by anybody after the `endTime`. This method finalizes the contribution period
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
  /// @notice check if tier cap has reached
  /// @return False if it's still open
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
  event InitializedTier(uint256 _tierNumber, address _tierAddress);
  event FinalizedTier(uint256 _tierCount, uint256 _now);
  event Refund(uint256 _amount);
  
}
```