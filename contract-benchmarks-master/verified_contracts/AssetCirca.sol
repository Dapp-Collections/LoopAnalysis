pragma solidity 0.4.24;
/**
* @title Circa Token Contract
* @dev Circa is an ERC-20 Standar Compliant Token
* @author Fares A. Akel C. <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="13753d727d677c7d7a7c3d7278767f53747e727a7f3d707c7e">[email protected]</a>&#13;
*/&#13;
&#13;
/**&#13;
 * @title SafeMath by OpenZeppelin (partially)&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
    /**&#13;
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
    */&#13;
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Adds two numbers, throws on overflow.&#13;
    */&#13;
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
        c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
* @title Admin parameters&#13;
* @dev Define administration parameters for this contract&#13;
*/&#13;
contract admined { //This token contract is administered&#13;
    address public admin; //Admin address is public&#13;
    address public allowedAddress; //An allowed address&#13;
    bool public lockSupply; //Burn Lock flag&#13;
    bool public lockTransfer = true; //Global transfers flag&#13;
&#13;
    /**&#13;
    * @dev Contract constructor&#13;
    * define initial administrator&#13;
    */&#13;
    constructor() internal {&#13;
        admin = 0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B; //Set initial admin&#13;
        emit Admined(admin);&#13;
    }&#13;
&#13;
    modifier onlyAdmin() { //A modifier to define admin-only functions&#13;
        require(msg.sender == admin);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyAllowed() { //A modifier to let allowedAddress work&#13;
        require(msg.sender == allowedAddress || msg.sender == admin || lockTransfer == false);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier supplyLock() { //A modifier to lock burn transactions&#13;
        require(lockSupply == false);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Function to set new admin address&#13;
    * @param _newAdmin The address to transfer administration to&#13;
    */&#13;
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered&#13;
        require(_newAdmin != 0);&#13;
        admin = _newAdmin;&#13;
        emit TransferAdminship(admin);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Function to set new allowed address&#13;
    * @param _newAllowed The address to transfer rights to&#13;
    */&#13;
    function setAllowed(address _newAllowed) onlyAdmin public { //Admin can be transfered&#13;
        allowedAddress = _newAllowed;&#13;
        emit SetAllowedAddress(allowedAddress);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Function to set burn lock&#13;
    * This function will be used after the burn process finish&#13;
    */&#13;
    function setSupplyLock(bool _flag) onlyAdmin public { //Only the admin can set a lock on supply&#13;
        lockSupply = _flag;&#13;
        emit SetSupplyLock(lockSupply);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Function to set transfer lock&#13;
    */&#13;
    function setTransferLock(bool _flag) onlyAdmin public { //Only the admin can set a lock on transfers&#13;
        lockTransfer = _flag;&#13;
        emit SetTransferLock(lockTransfer);&#13;
    }&#13;
&#13;
    //All admin actions have a log for public review&#13;
    event SetSupplyLock(bool _set);&#13;
    event SetTransferLock(bool _set);&#13;
    event SetAllowedAddress(address newAllowed);&#13;
    event TransferAdminship(address newAdminister);&#13;
    event Admined(address administer);&#13;
&#13;
}&#13;
&#13;
/**&#13;
* @title ERC20 interface&#13;
* @dev see https://github.com/ethereum/EIPs/issues/20&#13;
*/&#13;
contract ERC20 {&#13;
    function totalSupply() public view returns (uint256);&#13;
    function balanceOf(address who) public view returns (uint256);&#13;
    function transfer(address to, uint256 value) public returns (bool);&#13;
    function allowance(address owner, address spender) public view returns (uint256);&#13;
    function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
    function approve(address spender, uint256 value) public returns (bool);&#13;
    event Transfer(address indexed from, address indexed to, uint256 value);&#13;
    event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
&#13;
/**&#13;
* @title ERC20Token&#13;
* @notice Token definition contract&#13;
*/&#13;
contract ERC20Token is admined, ERC20 { //Standar definition of an ERC20Token&#13;
    using SafeMath for uint256; //SafeMath is used for uint256 operations&#13;
    mapping (address =&gt; uint256) internal balances; //A mapping of all balances per address&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed; //A mapping of all allowances&#13;
    uint256 internal totalSupply_;&#13;
&#13;
    /**&#13;
    * @dev total number of tokens in existence&#13;
    */&#13;
    function totalSupply() public view returns (uint256) {&#13;
        return totalSupply_;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Get the balance of an _who address.&#13;
    * @param _who The address to be query.&#13;
    */&#13;
    function balanceOf(address _who) public view returns (uint256) {&#13;
        return balances[_who];&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice transfer _value tokens to address _to&#13;
    * @param _to The address to transfer to.&#13;
    * @param _value The amount to be transferred.&#13;
    * @return success with boolean value true if done&#13;
    */&#13;
    function transfer(address _to, uint256 _value) onlyAllowed() public returns (bool) {&#13;
        require(_to != address(0)); //Invalid transfer&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        emit Transfer(msg.sender, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Get the allowance of an specified address to use another address balance.&#13;
    * @param _owner The address of the owner of the tokens.&#13;
    * @param _spender The address of the allowed spender.&#13;
    * @return remaining with the allowance value&#13;
    */&#13;
    function allowance(address _owner, address _spender) public view returns (uint256) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Transfer _value tokens from address _from to address _to using allowance msg.sender allowance on _from&#13;
    * @param _from The address where tokens comes.&#13;
    * @param _to The address to transfer to.&#13;
    * @param _value The amount to be transferred.&#13;
    * @return success with boolean value true if done&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint256 _value) onlyAllowed() public returns (bool) {&#13;
        require(_to != address(0)); //Invalid transfer&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        emit Transfer(_from, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Assign allowance _value to _spender address to use the msg.sender balance&#13;
    * @param _spender The address to be allowed to spend.&#13;
    * @param _value The amount to be allowed.&#13;
    * @return success with boolean value true&#13;
    */&#13;
    function approve(address _spender, uint256 _value) public returns (bool) {&#13;
        require((_value == 0) || (allowed[msg.sender][_spender] == 0)); //exploit mitigation&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Burn token of an specified address.&#13;
    * @param _burnedAmount amount to burn.&#13;
    */&#13;
    function burnToken(uint256 _burnedAmount) supplyLock() onlyAllowed() public returns (bool){&#13;
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _burnedAmount);&#13;
        totalSupply_ = SafeMath.sub(totalSupply_, _burnedAmount);&#13;
        emit Burned(msg.sender, _burnedAmount);&#13;
        return true;&#13;
    }&#13;
&#13;
    event Burned(address indexed _target, uint256 _value);&#13;
&#13;
}&#13;
&#13;
/**&#13;
* @title AssetCirca&#13;
* @notice Circa Token creation.&#13;
* @dev ERC20 Token compliant&#13;
*/&#13;
contract AssetCirca is ERC20Token {&#13;
    string public name = 'Circa';&#13;
    uint8 public decimals = 18;&#13;
    string public symbol = 'CIR';&#13;
    string public version = '1';&#13;
&#13;
    /**&#13;
    * @notice token contructor.&#13;
    */&#13;
    constructor() public {&#13;
        totalSupply_ = 1000000000 * 10 ** uint256(decimals); //Initial tokens supply 1,000,000,000;&#13;
        //Writer's equity&#13;
        balances[0xEB53AD38f0C37C0162E3D1D4666e63a55EfFC65f] = totalSupply_ / 1000; //0.1%&#13;
        balances[0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B] = totalSupply_.sub(balances[0xEB53AD38f0C37C0162E3D1D4666e63a55EfFC65f]); //99.9%&#13;
&#13;
        emit Transfer(0, this, totalSupply_);&#13;
        emit Transfer(this, 0xEB53AD38f0C37C0162E3D1D4666e63a55EfFC65f, balances[0xEB53AD38f0C37C0162E3D1D4666e63a55EfFC65f]);&#13;
        emit Transfer(this, 0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B, balances[0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B]);&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
    * @notice this contract will revert on direct non-function calls, also it's not payable&#13;
    * @dev Function to handle callback calls to contract&#13;
    */&#13;
    function() public {&#13;
        revert();&#13;
    }&#13;
&#13;
}