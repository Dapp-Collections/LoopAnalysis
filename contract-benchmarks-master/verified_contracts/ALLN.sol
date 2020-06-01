pragma solidity 0.4.21;
// sol token
// 
// Professor Rui-Shan Lu Team
// Lursun <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="acc0d9dedfd9c2959d989c9d9feccbc1cdc5c082cfc3c1">[email protected]</a>&gt;&#13;
// reference https://ethereum.org/token&#13;
&#13;
contract owned {&#13;
    address public owner;&#13;
&#13;
    function owned() public {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    modifier onlyOwner {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    function transferOwnership(address newOwner) onlyOwner public {&#13;
        owner = newOwner;&#13;
    }&#13;
}&#13;
&#13;
contract TokenERC20 is owned {&#13;
    address public deployer;&#13;
    // Public variables of the token&#13;
    string public name ="Airline &amp; Life Networking";&#13;
    string public symbol = "ALLN";&#13;
    uint8 public decimals = 4;&#13;
    // 18 decimals is the strongly suggested default, avoid changing it&#13;
    uint256 public totalSupply;&#13;
&#13;
    // This creates an array with all balances&#13;
    mapping (address =&gt; uint256) public balanceOf;&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) public allowance;&#13;
&#13;
    event Approval(address indexed owner, address indexed spender, uint value);&#13;
&#13;
    // This generates a public event on the blockchain that will notify clients&#13;
    event Transfer(address indexed from, address indexed to, uint256 value);&#13;
&#13;
    // This notifies clients about the amount burnt&#13;
    event Burn(address indexed from, uint256 value);&#13;
&#13;
    /**&#13;
     * Constrctor function&#13;
     *&#13;
     * Initializes contract with initial supply tokens to the creator of the contract&#13;
     */&#13;
    function TokenERC20() public {&#13;
        deployer = msg.sender;&#13;
    }&#13;
&#13;
    /**&#13;
     * Internal transfer, only can be called by this contract&#13;
     */&#13;
    function _transfer(address _from, address _to, uint _value) internal {&#13;
        // Prevent transfer to 0x0 address. Use burn() instead&#13;
        require(_to != 0x0);&#13;
        // Check if the sender has enough&#13;
        require(balanceOf[_from] &gt;= _value);&#13;
        // Check for overflows&#13;
        require(balanceOf[_to] + _value &gt;= balanceOf[_to]);&#13;
        // Save this for an assertion in the future&#13;
        uint previousBalances = balanceOf[_from] + balanceOf[_to];&#13;
        // Subtract from the sender&#13;
        balanceOf[_from] -= _value;&#13;
        // Add the same to the recipient&#13;
        balanceOf[_to] += _value;&#13;
        emit Transfer(_from, _to, _value);&#13;
        // Asserts are used to use static analysis to find bugs in your code. They should never fail&#13;
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);&#13;
    }&#13;
&#13;
    /**&#13;
     * Transfer tokens&#13;
     *&#13;
     * Send `_value` tokens to `_to` from your account&#13;
     *&#13;
     * @param _to The address of the recipient&#13;
     * @param _value the amount to send&#13;
     */&#13;
    function transfer(address _to, uint256 _value) public {&#13;
        _transfer(msg.sender, _to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * Transfer tokens from other address&#13;
     *&#13;
     * Send `_value` tokens to `_to` in behalf of `_from`&#13;
     *&#13;
     * @param _from The address of the sender&#13;
     * @param _to The address of the recipient&#13;
     * @param _value the amount to send&#13;
     */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {&#13;
        require(allowance[_from][msg.sender] &gt;= _value);     // Check allowance&#13;
        allowance[_from][msg.sender] -= _value;&#13;
        _transfer(_from, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Set allowance for other address&#13;
     *&#13;
     * Allows `_spender` to spend no more than `_value` tokens in your behalf&#13;
     *&#13;
     * @param _spender The address authorized to spend&#13;
     * @param _value the max amount they can spend&#13;
     */&#13;
    function approve(address _spender, uint256 _value) public returns (bool success) {&#13;
        allowance[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Destroy tokens&#13;
     *&#13;
     * Remove `_value` tokens from the system irreversibly&#13;
     *&#13;
     * @param _value the amount of money to burn&#13;
     */&#13;
    function burn(uint256 _value) onlyOwner public returns (bool success) {&#13;
        require(balanceOf[msg.sender] &gt;= _value);   // Check if the sender has enough&#13;
        balanceOf[msg.sender] -= _value;            // Subtract from the sender&#13;
        totalSupply -= _value;                      // Updates totalSupply&#13;
        emit Burn(msg.sender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
}&#13;
&#13;
/******************************************/&#13;
/*       ADVANCED TOKEN STARTS HERE       */&#13;
/******************************************/&#13;
&#13;
contract MyAdvancedToken is TokenERC20 {&#13;
    mapping (address =&gt; bool) public frozenAccount;&#13;
&#13;
    /* This generates a public event on the blockchain that will notify clients */&#13;
    event FrozenFunds(address target, bool frozen);&#13;
&#13;
    /* Initializes contract with initial supply tokens to the creator of the contract */&#13;
    function MyAdvancedToken() TokenERC20() public {}&#13;
&#13;
    /* Internal transfer, only can be called by this contract */&#13;
    function _transfer(address _from, address _to, uint _value) internal {&#13;
        require(_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead&#13;
        require(balanceOf[_from] &gt;= _value);               // Check if the sender has enough&#13;
        require(balanceOf[_to] + _value &gt; balanceOf[_to]); // Check for overflows&#13;
        require(!frozenAccount[_from]);                     // Check if sender is frozen&#13;
        require(!frozenAccount[_to]);                       // Check if recipient is frozen&#13;
        balanceOf[_from] -= _value;                         // Subtract from the sender&#13;
        balanceOf[_to] += _value;                           // Add the same to the recipient&#13;
        Transfer(_from, _to, _value);&#13;
    }&#13;
&#13;
    /// @notice Create `mintedAmount` tokens and send it to `target`&#13;
    /// @param target Address to receive the tokens&#13;
    /// @param mintedAmount the amount of tokens it will receive&#13;
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {&#13;
        uint tempSupply = totalSupply;&#13;
        balanceOf[target] += mintedAmount;&#13;
        totalSupply += mintedAmount;&#13;
        require(totalSupply &gt;= tempSupply);&#13;
        Transfer(0, this, mintedAmount);&#13;
        Transfer(this, target, mintedAmount);&#13;
    }&#13;
&#13;
    /// @notice `freeze? Prevent | Allow` `target` from sending &amp; receiving tokens&#13;
    /// @param target Address to be frozen&#13;
    /// @param freeze either to freeze it or not&#13;
    function freezeAccount(address target, bool freeze) onlyOwner public {&#13;
        frozenAccount[target] = freeze;&#13;
        emit FrozenFunds(target, freeze);&#13;
    }&#13;
&#13;
    function () payable public {&#13;
        require(false);&#13;
    }&#13;
&#13;
}&#13;
&#13;
contract ALLN is MyAdvancedToken {&#13;
    mapping(address =&gt; uint) public lockdate;&#13;
    mapping(address =&gt; uint) public lockTokenBalance;&#13;
&#13;
    event LockToken(address account, uint amount, uint unixtime);&#13;
&#13;
    function ALLN() MyAdvancedToken() public {}&#13;
    function getLockBalance(address account) internal returns(uint) {&#13;
        if(now &gt;= lockdate[account]) {&#13;
            lockdate[account] = 0;&#13;
            lockTokenBalance[account] = 0;&#13;
        }&#13;
        return lockTokenBalance[account];&#13;
    }&#13;
&#13;
    /* Internal transfer, only can be called by this contract */&#13;
    function _transfer(address _from, address _to, uint _value) internal {&#13;
        uint usableBalance = balanceOf[_from] - getLockBalance(_from);&#13;
        require(balanceOf[_from] &gt;= usableBalance);&#13;
        require(_to != 0x0);                                // Prevent transfer to 0x0 address. Use burn() instead&#13;
        require(usableBalance &gt;= _value);                   // Check if the sender has enough&#13;
        require(balanceOf[_to] + _value &gt; balanceOf[_to]);  // Check for overflows&#13;
        require(!frozenAccount[_from]);                     // Check if sender is frozen&#13;
        require(!frozenAccount[_to]);                       // Check if recipient is frozen&#13;
        balanceOf[_from] -= _value;                         // Subtract from the sender&#13;
        balanceOf[_to] += _value;                           // Add the same to the recipient&#13;
        emit Transfer(_from, _to, _value);&#13;
    }&#13;
&#13;
&#13;
    function lockTokenToDate(address account, uint amount, uint unixtime) onlyOwner public {&#13;
        require(unixtime &gt;= lockdate[account]);&#13;
        require(unixtime &gt;= now);&#13;
        if(balanceOf[account] &gt;= amount) {&#13;
            lockdate[account] = unixtime;&#13;
            lockTokenBalance[account] = amount;&#13;
            emit LockToken(account, amount, unixtime);&#13;
        }&#13;
    }&#13;
&#13;
    function lockTokenDays(address account, uint amount, uint _days) public {&#13;
        uint unixtime = _days * 1 days + now;&#13;
        lockTokenToDate(account, amount, unixtime);&#13;
    }&#13;
&#13;
     /**&#13;
     * Destroy tokens&#13;
     *&#13;
     * Remove `_value` tokens from the system irreversibly&#13;
     *&#13;
     * @param _value the amount of money to burn&#13;
     */&#13;
    function burn(uint256 _value) onlyOwner public returns (bool success) {&#13;
        uint usableBalance = balanceOf[msg.sender] - getLockBalance(msg.sender);&#13;
        require(balanceOf[msg.sender] &gt;= usableBalance);&#13;
        require(usableBalance &gt;= _value);           // Check if the sender has enough&#13;
        balanceOf[msg.sender] -= _value;            // Subtract from the sender&#13;
        totalSupply -= _value;                      // Updates totalSupply&#13;
        emit Burn(msg.sender, _value);&#13;
        return true;&#13;
    }&#13;
}