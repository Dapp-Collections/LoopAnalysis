pragma solidity ^0.4.18;
/*
The Cowboy coin

ERC-20 Token Standard Compliant
EIP-621 Compliant

Contract developer: Oyewole Samuel <span class="__cf_email__" data-cfemail="b8dad1ccdbddcaccf8dfd5d9d1d496dbd7d5">[email protected]</span>&#13;
&#13;
Token name is Cowboy coin&#13;
Token symbol is CWBY&#13;
Total Token supply is 100 million tokens with associated digital format (1.00)&#13;
Token decimals can be standard&#13;
Order: FO71192BC2945&#13;
*/&#13;
&#13;
/**&#13;
 * @title SafeMath by OpenZeppelin&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
    }&#13;
&#13;
    function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        uint256 c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * This contract is administered&#13;
 */&#13;
&#13;
contract admined {&#13;
    address public admin; //Admin address is public&#13;
    address public allowed;//Allowed addres is public&#13;
&#13;
    bool public locked = true; //initially locked&#13;
    /**&#13;
    * @dev This constructor set the initial admin of the contract&#13;
    */&#13;
    function admined() internal {&#13;
        admin = msg.sender; //Set initial admin to contract creator&#13;
        emit Admined(admin);&#13;
    }&#13;
&#13;
    modifier onlyAdmin() { //A modifier to define admin-allowed functions&#13;
        require(msg.sender == admin || msg.sender == allowed);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier lock() { //A modifier to lock specific supply functions&#13;
        require(locked == false);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    function allowedAddress(address _allowed) onlyAdmin public {&#13;
        allowed = _allowed;&#13;
        emit Allowed(_allowed);&#13;
    }&#13;
    /**&#13;
    * @dev Transfer the adminship of the contract&#13;
    * @param _newAdmin The address of the new admin.&#13;
    */&#13;
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered&#13;
        require(_newAdmin != address(0));&#13;
        admin = _newAdmin;&#13;
        emit TransferAdminship(admin);&#13;
    }&#13;
    /**&#13;
    * @dev Enable or disable lock&#13;
    * @param _locked Status.&#13;
    */&#13;
    function lockSupply(bool _locked) onlyAdmin public {&#13;
        locked = _locked;&#13;
        emit LockedSupply(locked);&#13;
    }&#13;
&#13;
    //All admin actions have a log for public review&#13;
    event TransferAdminship(address newAdmin);&#13;
    event Admined(address administrador);&#13;
    event LockedSupply(bool status);&#13;
    event Allowed(address allow);&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * Token contract interface for external use&#13;
 */&#13;
contract ERC20TokenInterface {&#13;
&#13;
    function balanceOf(address _owner) public constant returns (uint256 balance);&#13;
    function transfer(address _to, uint256 _value) public returns (bool success);&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);&#13;
    function approve(address _spender, uint256 _value) public returns (bool success);&#13;
}&#13;
&#13;
&#13;
contract ERC20Token is admined, ERC20TokenInterface { //Standar definition of an ERC20Token&#13;
    &#13;
    using SafeMath for uint256;&#13;
    &#13;
    uint256 totalSupply_;&#13;
    &#13;
    mapping (address =&gt; uint256) balances; //A mapping of all balances per address&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed; //A mapping of all allowances&#13;
&#13;
    /**&#13;
    * @dev Get the balance of an specified address.&#13;
    * @param _owner The address to be query.&#13;
    */&#13;
    function balanceOf(address _owner) public constant returns (uint256 balance) {&#13;
      return balances[_owner];&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev total number of tokens in existence&#13;
    */&#13;
    function totalSupply() public view returns (uint256) {&#13;
        return totalSupply_;&#13;
    }    &#13;
&#13;
    /**&#13;
    * @dev transfer token to a specified address&#13;
    * @param _to The address to transfer to.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transfer(address _to, uint256 _value) public returns (bool success) {&#13;
        require(_to != address(0)); //If you dont want that people destroy token&#13;
        require(balances[msg.sender] &gt;= _value);&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        emit Transfer(msg.sender, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev transfer token from an address to another specified address using allowance&#13;
    * @param _from The address where token comes.&#13;
    * @param _to The address to transfer to.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {&#13;
        require(_to != address(0)); //If you dont want that people destroy token&#13;
        require(balances[_from] &gt;= _value &amp;&amp; allowed[_from][msg.sender] &gt;= _value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
        emit Transfer(_from, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Assign allowance to an specified address to use the owner balance&#13;
    * @param _spender The address to be allowed to spend.&#13;
    * @param _value The amount to be allowed.&#13;
    */&#13;
    function approve(address _spender, uint256 _value) public returns (bool success) {&#13;
      allowed[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Get the allowance of an specified address to use another address balance.&#13;
    * @param _owner The address of the owner of the tokens.&#13;
    * @param _spender The address of the allowed spender.&#13;
    */&#13;
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {&#13;
    return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    /**&#13;
    *Log Events&#13;
    */&#13;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);&#13;
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);&#13;
}&#13;
&#13;
contract Cowboy is admined, ERC20Token {&#13;
    &#13;
    string public name = "Cowboy Coin";&#13;
    string public symbol = "CWBY";&#13;
    string public version = "1.0";&#13;
    uint8 public decimals = 18;&#13;
    &#13;
    //address of the beneficiary&#13;
    address public beneficiary = 0x9bF52817A5103A9095706FB0b9a027fCEA0e18Cf;&#13;
&#13;
    function Cowboy() public {&#13;
        totalSupply_ = 100000000 * (10**uint256(decimals));&#13;
        balances[this] = totalSupply_;&#13;
        //Allow owner contract&#13;
        allowed[this][beneficiary] = balances[this]; //Contract balance is allowed to creator&#13;
        &#13;
        _transferTokenToOwner();&#13;
&#13;
        /**&#13;
        *Log Events&#13;
        */&#13;
        emit Transfer(0, this, totalSupply_);&#13;
        emit Approval(this, beneficiary, balances[this]);&#13;
&#13;
    }&#13;
    &#13;
    function _transferTokenToOwner() internal {&#13;
        balances[this] = balances[this].sub(totalSupply_);&#13;
        balances[beneficiary] = balances[beneficiary].add(totalSupply_);&#13;
        emit Transfer(this, beneficiary, totalSupply_);&#13;
    }    &#13;
    &#13;
    function giveReward(address _from, address _buyer, uint256 _value) public returns (bool success) {&#13;
        require(_buyer != address(0));&#13;
        require(balances[_from] &gt;= _value);&#13;
&#13;
        balances[_buyer] = balances[_buyer].add(_value);&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        emit Transfer(_from, _buyer, _value);&#13;
        return true;&#13;
    }&#13;
    &#13;
    /**&#13;
    *@dev Function to handle callback calls&#13;
    */&#13;
    function() public {&#13;
        revert();&#13;
    }&#13;
}