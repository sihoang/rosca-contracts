pragma solidity ^0.4.8;

import './lib/ERC20.sol';
import './lib/SafeMath.sol';
import './Trustcoin.sol'

contract Trustcoin2 is ERC20, SafeMath {

  string public name = 'Trustcoin2';
  uint8 public decimals = 18;
  string public symbol = 'TRST2';
  string public version = 'TRST2.0';
  uint256 public totalSupply;
  address public oldToken;
  bool public allowOldMigrations;
  uint256 public allowOldMigrationsUntil;

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  bool migrationActive;
  address migrationMaster;

  event Transfer(address from, address to, uint256 value);
  event Approval(address from, address to, uint256 value);
  event Migrate(address owner, uint256 value);
  event MigrateSuccess(address owner, uint256 value);
  event MigrationFinalized();

  function Trustcoin2(address _oldToken, address _migrationMaster, bool _allowOldMigrations, uint256 _allowOldMigrationsUntil) {
    if (_oldToken == 0) throw;
    if (_migrationMaster == 0) throw;
    if (_allowOldMigrationsUntil < (block.timestamp + 26 weeks)) throw;
    oldToken = _oldToken;
    migrationMaster = _migrationMaster;
    allowOldMigrations = _allowOldMigrations;
    allowOldMigrationsUntil = _allowOldMigrationsUntil;
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

  function setMigrationMaster(address _master) external {
    if (msg.sender != migrationMaster) throw;
    if (_master == 0) throw;
    migrationMaster = _master;
  }

  function setMigrationStatus(bool _active) external {
    if (msg.sender != migrationMaster) throw;
    migrationActive = _active;
  }

  function migrate(uint256 _value) external {
    if (!migrationActive) throw;
    if (_value == 0) throw;
    if (_value > balances[msg.sender]) throw;
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    totalSupply = safeSub(totalSupply, _value);
    totalMigrated = safeSub(totalMigrated, _value);
    Migrate(msg.sender, _value);
  }

  /**
   *  Migrates the specified token balance from msg.sender in the old contract
   *  to the new contract
   *  @param {uint256} _value Number of tokens to be migrated
   */
  function migrateOldTokens(uint256 _value) external {
    if (!allowOldMigrations) throw;
    if (_value == 0) throw;
    Trustcoin(oldToken).migrate(msg.sender, _value);
    totalSupply = safeAdd(totalSupply, _value);
    balances[msg.sender] = safeAdd(balances[msg.sender], _value);
    MigrateSuccess(msg.sender, _value);
  }

  /**
   *  Ends the possibility for any more tokens to be migrated from the old contract
   *  to the new one
   */
  function finalizeMigration() external {
    if (msg.sender != migrationMaster) throw;
    if (!allowOldMigrations) throw;
    if (now < allowOldMigrationsUntil) throw;
    allowOldMigrations = false;
    MigrationFinalized();
  }

}