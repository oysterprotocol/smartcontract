pragma solidity ^0.4.18;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract OysterPearl {
  // Public variables of PRL
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  uint256 public funds;
  address public director;
  bool public saleClosed;
  bool public directorLock;
  uint256 public claimAmount;
  uint256 public payPercentage:
  uint256 public feePercentage;
  uint256 public epoch;
  uint256 public retentionMax;

  // Array definitions
  mapping (bytes32 => uint256) public hashBalances;
  mapping (address => uint256) public balances;
  mapping (address => mapping (address => uint256)) public allowance;
  mapping (bytes32 => bool) public buried;
  mapping (bytes32 => address) public buryBroker;

  // ERC20 event
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
  // ERC20 event
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  // This notifies clients about the amount burnt
  event Burn(address indexed _from, uint256 _value);
    
  // This notifies clients about an address getting buried
  event Bury(bytes32 indexed _target, uint256 _value);
    
  // This notifies clients about a claim being made on a buried hash
  event Claim(bytes32 hash, address indexed _payout, address indexed _fee);
 
  // This notifies clients on a change of directorship
  event TransferDirector(address indexed _newDirector);

  /**
   * Constructor function
   *
   * Initializes contract
   */
  constructor() public payable {
    director = msg.sender;
    name = "Oyster Pearl";
    symbol = "PRL2";
    decimals = 18;
    saleClosed = true;
    directorLock = false;
    funds = 0;
    totalSupply = 0;

    // Marketing share (5%)
    totalSupply += 25000000 * 10 ** uint256(decimals);

    // Devfund share (15%)
    totalSupply += 75000000 * 10 ** uint256(decimals);

    // Allocation to match PREPRL supply and reservation for discretionary use
    totalSupply += 8000000 * 10 ** uint256(decimals);

    // Assign reserved PRL supply to the director
    balances[director] = totalSupply;

    // Define default values for Oyster functions
    claimAmount = 5 * 10 ** (uint256(decimals) - 1);
    payPercentage = 80;
    feePercentage = 20;

    // Seconds in a year
    epoch = 31536000;

    // Maximum time for a sector to remain stored
    retentionMax = 40 * 10 ** uint256(decimals);
  }

  /**
   * ERC20 balance function
   */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

  modifier onlyDirector {
    // Director can lock themselves out to complete decentralization of Oyster network
    // An alternative is that another smart contract could become the decentralized director
    require(!directorLock);

    // Only the director is permitted
    require(msg.sender == director);
    _;
  }

  modifier onlyDirectorForce {
    // Only the director is permitted
    require(msg.sender == director);
    _;
  }

  /**
   * Transfers the director to a new address
   */
  function transferDirector(address newDirector) public onlyDirectorForce {
    director = newDirector;
  }

  /**
   * Withdraw funds from the contract
   */
  function withdrawFunds() public onlyDirectorForce {
    director.transfer(this.balance);
  }

  /**
   * Permanently lock out the director to decentralize Oyster
   * Invocation is discretionary because Oyster might be better suited to
   * transition to an artificially intelligent smart contract director
   */
  function selfLock() public payable onlyDirector {
    // The sale must be closed before the director gets locked out
    require(saleClosed);

    // Prevents accidental lockout
    require(msg.value == 10 ether);
    
    // refunds security
    director.transfer(10 ether);

    // Permanently lock out the director
    directorLock = true;
  }

  /**
   * Director can alter the storage-peg and broker fees
   */
  function amendClaim(uint8 _claimAmount, uint8 _payPercentage, uint8 _feePercentage, uint8 accuracy) public onlyDirector returns (bool success) {
    require((_payPercentage + _feePercentage) == 100)
    require(_payPercentage >= 0);
    require(_feePercentage >= 0);

    claimAmount = claimAmount * 10 ** (uint256(decimals) - accuracy);
    payPercentage = _payPercentage;
    feePercentage = _feePercentage;
    
    return true;
  }

  /**
   * Director can alter the epoch time
   */
  function amendEpoch(uint256 epochSet) public onlyDirector returns (bool success) {
    // Set the epoch
    epoch = epochSet;
    return true;
  }

  /**
   * Director can alter the maximum time of storage retention
   */
  function amendRetention(uint8 retentionSet, uint8 accuracy) public onlyDirector returns (bool success) {
    // Set retentionMax
    retentionMax = retentionSet * 10 ** (uint256(decimals) - accuracy);
    return true;
  }

  /**
   * Oyster Protocol Function
   * More information at https://oyster.ws/OysterWhitepaper.pdf
   *
   * Bury an address
   *
   * When an address is buried; only claimAmount can be withdrawn once per epoch
   */
   function bury(bytes32 hash) public returns (bool success) {
     // The hash must be previously unburied
     require(!buried[hash]);
        
     // claimAmount is able to be transferred to this contract
     require(_transfer(msg.sender, address(this), claimAmount));
        
     // Assign buried PRL to this hash
     hashBalances[hash] += claimAmount;
        
     // Assign broker to this hash
     buryBroker[hash] = msg.sender;
        
     // An address must have at least claimAmount to be buried
     require(hashBalances[hash] >= claimAmount);
        
     // Set buried state to true
     buried[hash] = true;

        
     // Execute an event reflecting the change
     emit Bury(hash, hashBalances[hash]);
     return true;
    }

  /**
   * Oyster Protocol Function
   * More information at https://oyster.ws/OysterWhitepaper.pdf
   *
   * Claim PRL from a buried address
   *
   * If a prior claim wasn't made during the current epoch, then claimAmount can be withdrawn
   */
    function claim(bytes32 hash, bytes32 privateKey) public returns (bool success) {
     
     // Hash must be hash from private Key
     require(keccak256(privateKey) == hash);
        
     // The claimed address must have already been buried
     require(buried[hash]);
        
     // Check if the buried address has enough
     require(hashBalances[hash] >= claimAmount);
     
     // Save this for an assertion in the future
     uint256 previousBalances = hashBalances[hash] + balances[msg.sender] + balances[buryBroker[hash]];
     
     // Remove claimAmount from this contract
     balances[address(this)] -= hashBalances[hash]
     
     // Pay the website owner that invoked the web node that found the PRL seed key
     balances[msg.sender] += hashBalances[hash] * payPercentage / 100
        
     // Pay the broker node that unlocked the PRL
     balances[buryBroker[hash]] += hashBalances[hash] * feePercentage / 100
        
     // Remove claimAmount from the buried hashBalance
     hashBalances[hash] = 0;
        
     // Execute events to reflect the changes
     emit Claim(hash, msg.sender, buryBroker[hash]);
     
     // Failsafe logic that should never be false
     assert(hashBalances[hash] + balances[msg.sender] + balances[buryBroker[hash]] == previousBalances);
    
     return true;
    }
    
    function getHashBalances(bytes32 hash) public view returns(uint256){
        return hashBalances[hash];
    }
    

  /**
   * Internal transfer, can be called by this contract only
   */
  function _transfer(address _from, address _to, uint _value) internal returns (bool success) {

    // Prevent transfer to 0x0 address, use burn() instead
    require(_to != 0x0);

    // Check if the sender has enough
    require(balances[_from] >= _value);

    // Check for overflows
    require(balances[_to] + _value > balances[_to]);

    // Save this for an assertion in the future
    uint256 previousBalances = balances[_from] + balances[_to];

    // Subtract from the sender
    balances[_from] -= _value;

    // Add the same to the recipient
    balances[_to] += _value;
    emit Transfer(_from, _to, _value);

    // Failsafe logic that should never be false
    assert(balances[_from] + balances[_to] == previousBalances);
    
    return true;
  }

  /**
   * Transfer tokens
   *
   * Send `_value` tokens to `_to` from your account
   *
   * @param _to the address of the recipient
   * @param _value the amount to send
   */
  function transfer(address _to, uint256 _value) public {
    _transfer(msg.sender, _to, _value);
  }

  /**
   * Transfer tokens from other address
   *
   * Send `_value` tokens to `_to` in behalf of `_from`
   *
   * @param _from the address of the sender
   * @param _to the address of the recipient
   * @param _value the amount to send
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    // Check allowance
    require(_value <= allowance[_from][msg.sender]);
    allowance[_from][msg.sender] -= _value;
    _transfer(_from, _to, _value);
    return true;
  }

  /**
   * Set allowance for other address
   *
   * Allows `_spender` to spend no more than `_value` tokens on your behalf
   *
   * @param _spender the address authorized to spend
   * @param _value the max amount they can spend
   */
  function approve(address _spender, uint256 _value) public returns (bool success) {


    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * Set allowance for other address and notify
   *
   * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
   *
   * @param _spender the address authorized to spend
   * @param _value the max amount they can spend
   * @param _extraData some extra information to send to the approved contract
   */
  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
    tokenRecipient spender = tokenRecipient(_spender);
    if (approve(_spender, _value)) {
      spender.receiveApproval(msg.sender, _value, this, _extraData);
      return true;
    }
  }

  /**
   * Destroy tokens
   *
   * Remove `_value` tokens from the system irreversibly
   *
   * @param _value the amount of money to burn
   */
  function burn(uint256 _value) public returns (bool success) {

    // Check if the sender has enough
    require(balances[msg.sender] >= _value);

    // Subtract from the sender
    balances[msg.sender] -= _value;

    // Updates totalSupply
    totalSupply -= _value;
    emit Burn(msg.sender, _value);
    return true;
  }

  /**
   * Destroy tokens from other account
   *
   * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
   *
   * @param _from the address of the sender
   * @param _value the amount of money to burn
   */
  function burnFrom(address _from, uint256 _value) public returns (bool success) {

    // Check if the targeted balance is enough
    require(balances[_from] >= _value);

    // Check allowance
    require(_value <= allowance[_from][msg.sender]);

    // Subtract from the targeted balance
    balances[_from] -= _value;

    // Subtract from the sender's allowance
    allowance[_from][msg.sender] -= _value;

    // Update totalSupply
    totalSupply -= _value;
    emit Burn(_from, _value);
    return true;
  }
}
