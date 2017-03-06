pragma solidity ^0.4.8;

import './lib/ERC20.sol';
import './lib/SafeMath.sol';

contract Trustcoin is ERC20, SafeMath {

  string public name = 'Trustcoin';
  uint8 public decimals = 18;
  string public symbol = 'TRST';
  string public version = 'TRST1.0';
  uint256 public totalSupply = 100000000; // One hundred million
  uint256 public totalMigrated;
  address public newToken;

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  bool migrationActive;
  address migrationMaster;

  event Transfer(address from, address to, uint256 value);
  event Approval(address from, address to, uint256 value);
  event Migrate(address owner, uint256 value);

  function Trustcoin(address _migrationMaster) {
    if (_migrationMaster == 0) throw;
    migrationMaster = _migrationMaster;
  }

  function transfer(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];
    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  //
  // Migration methods
  //

  /**
   *  Sets the owner for the migration behaviour
   *  @param {address} _master Address of the migration controller
   */
  function setMigrationMaster(address _master) external {
    if (msg.sender != migrationMaster) throw;
    if (_master == 0) throw;
    migrationMaster = _master;
  }

  /**
   *  Activates the migration status
   */
  function allowMigrations() external {
    if (msg.sender != migrationMaster) throw;
    if (migrationActive) throw;
    migrationActive = true;
  }

  /**
   *  Sets the address of the new token contract, so we know who to
   *  accept migrate() calls from
   *  @param {address} _newToken Address of the new Trustcoin contract
   */
  function setNewToken(address _newToken) external {
    if (msg.sender != migrationMaster) throw;
    if (newToken != 0) throw;
    newToken = _newToken;
  }

  /**
   *  Burns the tokens from an address and increments the totalMigrated
   *  by the same value
   *  @param {address} _from Address which holds the tokens
   *  @param {uint256} _value Number of tokens to be migrated
   */
  function migrate(address _from, uint256 _value) external {
    if (!migrationActive) throw;
    if (msg.sender != newToken) throw;
    if (_value == 0) throw;
    if (_value > balances[_from]) throw;
    balances[_from] = safeSub(balances[_from], _value);
    totalSupply = safeSub(balances[_from], _value);
    totalMigrated = safeAdd(totalMigrated, _value);
    Migrate(_from, _value);
  }

}