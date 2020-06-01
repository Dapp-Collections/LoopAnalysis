pragma solidity ^0.4.11;
/**
    ERC20 Interface
    @author DongOk Peter Ryu - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4e212a27200e3729292a3c2f3d26602721">[email protected]</a>&gt;&#13;
*/&#13;
contract ERC20 {&#13;
    function totalSupply() public constant returns (uint supply);&#13;
    function balanceOf( address who ) public constant returns (uint value);&#13;
    function allowance( address owner, address spender ) public constant returns (uint _allowance);&#13;
&#13;
    function transfer( address to, uint value) public returns (bool ok);&#13;
    function transferFrom( address from, address to, uint value) public returns (bool ok);&#13;
    function approve( address spender, uint value ) public returns (bool ok);&#13;
&#13;
    event Transfer( address indexed from, address indexed to, uint value);&#13;
    event Approval( address indexed owner, address indexed spender, uint value);&#13;
}&#13;
&#13;
/**&#13;
    LOCKABLE TOKEN&#13;
    @author DongOk Peter Ryu - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6609020f08261f0101021407150e480f09">[email protected]</a>&gt;&#13;
*/&#13;
contract Lockable {&#13;
    uint public creationTime;&#13;
    bool public lock;&#13;
    bool public tokenTransfer;&#13;
    address public owner;&#13;
    mapping( address =&gt; bool ) public unlockaddress;&#13;
    // lockaddress List&#13;
    mapping( address =&gt; bool ) public lockaddress;&#13;
&#13;
    // LOCK EVENT&#13;
    event Locked(address lockaddress,bool status);&#13;
    // UNLOCK EVENT&#13;
    event Unlocked(address unlockedaddress, bool status);&#13;
&#13;
&#13;
    // if Token transfer&#13;
    modifier isTokenTransfer {&#13;
        // if token transfer is not allow&#13;
        if(!tokenTransfer) {&#13;
            require(unlockaddress[msg.sender]);&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    // This modifier check whether the contract should be in a locked&#13;
    // or unlocked state, then acts and updates accordingly if&#13;
    // necessary&#13;
    modifier checkLock {&#13;
        assert(!lockaddress[msg.sender]);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isOwner&#13;
    {&#13;
        require(owner == msg.sender);&#13;
        _;&#13;
    }&#13;
&#13;
    function Lockable()&#13;
    public&#13;
    {&#13;
        creationTime = now;&#13;
        tokenTransfer = false;&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    // Lock Address&#13;
    function lockAddress(address target, bool status)&#13;
    external&#13;
    isOwner&#13;
    {&#13;
        require(owner != target);&#13;
        lockaddress[target] = status;&#13;
        Locked(target, status);&#13;
    }&#13;
&#13;
    // UnLock Address&#13;
    function unlockAddress(address target, bool status)&#13;
    external&#13;
    isOwner&#13;
    {&#13;
        unlockaddress[target] = status;&#13;
        Unlocked(target, status);&#13;
    }&#13;
}&#13;
&#13;
&#13;
library SafeMath {&#13;
  function mul(uint a, uint b) internal returns (uint) {&#13;
    uint c = a * b;&#13;
    assert(a == 0 || c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  function div(uint a, uint b) internal returns (uint) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  function sub(uint a, uint b) internal returns (uint) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  function add(uint a, uint b) internal returns (uint) {&#13;
    uint c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
&#13;
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {&#13;
    return a &gt;= b ? a : b;&#13;
  }&#13;
&#13;
  function min64(uint64 a, uint64 b) internal constant returns (uint64) {&#13;
    return a &lt; b ? a : b;&#13;
  }&#13;
&#13;
  function max256(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    return a &gt;= b ? a : b;&#13;
  }&#13;
&#13;
  function min256(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    return a &lt; b ? a : b;&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
    YGGDRASH Token&#13;
    @author DongOk Peter Ryu - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3758535e59774e5050534556445f195e58">[email protected]</a>&gt;&#13;
*/&#13;
contract YeedToken is ERC20, Lockable {&#13;
    using SafeMath for uint;&#13;
&#13;
    mapping( address =&gt; uint ) _balances;&#13;
    mapping( address =&gt; mapping( address =&gt; uint ) ) _approvals;&#13;
    uint _supply;&#13;
    address public walletAddress;&#13;
&#13;
    event TokenBurned(address burnAddress, uint amountOfTokens);&#13;
    event TokenTransfer();&#13;
&#13;
    modifier onlyFromWallet {&#13;
        require(msg.sender != walletAddress);&#13;
        _;&#13;
    }&#13;
&#13;
    function YeedToken( uint initial_balance, address wallet)&#13;
    public&#13;
    {&#13;
        require(wallet != 0);&#13;
        require(initial_balance != 0);&#13;
        _balances[msg.sender] = initial_balance;&#13;
        _supply = initial_balance;&#13;
        walletAddress = wallet;&#13;
    }&#13;
&#13;
    function totalSupply() public constant returns (uint supply) {&#13;
        return _supply;&#13;
    }&#13;
&#13;
    function balanceOf( address who ) public constant returns (uint value) {&#13;
        return _balances[who];&#13;
    }&#13;
&#13;
    function allowance(address owner, address spender) public constant returns (uint _allowance) {&#13;
        return _approvals[owner][spender];&#13;
    }&#13;
&#13;
    function transfer( address to, uint value)&#13;
    public&#13;
    isTokenTransfer&#13;
    checkLock&#13;
    returns (bool success) {&#13;
&#13;
        require( _balances[msg.sender] &gt;= value );&#13;
&#13;
        _balances[msg.sender] = _balances[msg.sender].sub(value);&#13;
        _balances[to] = _balances[to].add(value);&#13;
        Transfer( msg.sender, to, value );&#13;
        return true;&#13;
    }&#13;
&#13;
    function transferFrom( address from, address to, uint value)&#13;
    public&#13;
    isTokenTransfer&#13;
    checkLock&#13;
    returns (bool success) {&#13;
        // if you don't have enough balance, throw&#13;
        require( _balances[from] &gt;= value );&#13;
        // if you don't have approval, throw&#13;
        require( _approvals[from][msg.sender] &gt;= value );&#13;
        // transfer and return true&#13;
        _approvals[from][msg.sender] = _approvals[from][msg.sender].sub(value);&#13;
        _balances[from] = _balances[from].sub(value);&#13;
        _balances[to] = _balances[to].add(value);&#13;
        Transfer( from, to, value );&#13;
        return true;&#13;
    }&#13;
&#13;
    function approve(address spender, uint value)&#13;
    public&#13;
    checkLock&#13;
    returns (bool success) {&#13;
        _approvals[msg.sender][spender] = value;&#13;
        Approval( msg.sender, spender, value );&#13;
        return true;&#13;
    }&#13;
&#13;
    // burnToken burn tokensAmount for sender balance&#13;
    function burnTokens(uint tokensAmount)&#13;
    public&#13;
    isTokenTransfer&#13;
    {&#13;
        require( _balances[msg.sender] &gt;= tokensAmount );&#13;
&#13;
        _balances[msg.sender] = _balances[msg.sender].sub(tokensAmount);&#13;
        _supply = _supply.sub(tokensAmount);&#13;
        TokenBurned(msg.sender, tokensAmount);&#13;
&#13;
    }&#13;
&#13;
&#13;
    function enableTokenTransfer()&#13;
    external&#13;
    onlyFromWallet&#13;
    {&#13;
        tokenTransfer = true;&#13;
        TokenTransfer();&#13;
    }&#13;
&#13;
    function disableTokenTransfer()&#13;
    external&#13;
    onlyFromWallet&#13;
    {&#13;
        tokenTransfer = false;&#13;
        TokenTransfer();&#13;
    }&#13;
&#13;
    /* This unnamed function is called whenever someone tries to send ether to it */&#13;
    function () public payable {&#13;
        revert();&#13;
    }&#13;
&#13;
}