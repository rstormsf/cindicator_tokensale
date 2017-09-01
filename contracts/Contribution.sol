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
  bool public transferable;
  address public contributionWallet;

  uint256 public totalSold;                 // How much tokens have been sold

  bool public paused;

  modifier capNotReached() {
    Tier tier = tiers[tierCount];
    assert(tier.cap() > tier.totalInvestedWei());
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

  function Contribution(address _cnd, address _contributionWallet) {
    require(_contributionWallet != 0x0);
    assert(CND(_cnd).IS_CND_CONTRACT_MAGIC_NUMBER() == 0x1338);
    require(_cnd != 0x0);
    contributionWallet = _contributionWallet;
    cnd = CND(_cnd);
    tierCount = 0;
  }

  function initializeTier(
      uint256 _tierNumber,
      address _tierAddress
  ) public onlyController 
  {
    Tier tier = Tier(_tierAddress);
    assert(tier.controller() == address(this));
    require(_tierNumber >= 0 && _tierNumber <= 3);
    assert(tier.IS_TIER_CONTRACT_MAGIC_NUMBER() == 0x1337);
    // check if tier is not defined
    assert(tiers[_tierNumber] == address(0));
    tiers[_tierNumber] = tier;
    InitializedTier(_tierNumber, _tierAddress);
  }

  /// @notice If anybody sends Ether directly to this contract, consider he is
  /// getting CND.
  function () public payable notPaused {
    proxyPayment(msg.sender);
  }

  function investorAmountTokensToBuy(address _investor) public returns(uint256) {
       WhitelistedInvestor investor = investors[_investor];
       Tier tier = tiers[tierCount];
       uint256 leftToBuy = tier.maxInvestorCap().sub(investor.contributedAmount);
       return leftToBuy;
  }

  function isWhitelisted(address _investor, uint256 _tier) public constant returns(bool) {
       WhitelistedInvestor investor = investors[_investor];
       return (investor.tier <= _tier && investor.status);
  }

  function whitelistAddresses(address[] _addresses, uint256 _tier, bool _status) public onlyController {
        for (uint256 i = 0; i < _addresses.length; i++) {
            address investorAddress = _addresses[i];
            require(investors[investorAddress].contributedAmount == 0);
            investors[investorAddress] = WhitelistedInvestor(_tier, _status, 0);
       }
   }

  /// @notice This method will generally be called by the CND token contract to
  ///  acquire CNDs. Or directly from third parties that want to acquire AIXs in
  ///  behalf of a token holder.
  /// @param _th CND holder where the CNDs will be minted.
  function proxyPayment(address _th) public payable 
      notPaused
      initialized
      capNotReached 
      returns (bool) 
  {
    assert(contributionOpen());
    require(isWhitelisted(_th, tierCount));
    require(_th != 0x0);
    doBuy(_th);
    return true;
  }

  function onTransfer(address, address, uint256) public returns (bool) {
    return transferable;
  }

  function onApprove(address, address, uint256) public returns (bool) {
    return transferable;
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

  function doBuy(address _th) internal {
    Tier tier = tiers[tierCount];
    assert(msg.value >= tier.minInvestorCap());
    // Antispam mechanism
    address caller;
    if (msg.sender == address(cnd)) {
      caller = _th;
    } else {
      caller = msg.sender;
    }
    assert(!isContract(caller));
    WhitelistedInvestor investor = investors[caller];
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
      tierCount++;
    }
    
    assert(cnd.generateTokens(_th, tokensGenerated));
    totalSold = totalSold.add(tokensGenerated);
    contributionWallet.transfer(toFund);
    NewSale(_th, toFund, tokensGenerated);
    uint256 toReturn = msg.value.sub(toFund);
    if (toReturn > 0) {
      caller.transfer(toReturn);
    }
  }

  /// @dev Internal function to determine if an address is a contract
  /// @param _addr The address being queried
  /// @return True if `_addr` is a contract
  function isContract(address _addr) constant internal returns (bool) {
    if (_addr == 0) return false;
    uint256 size;
    assembly {
      size := extcodesize(_addr)
    }
    return (size > 0);
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
}
