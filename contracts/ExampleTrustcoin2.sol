/**
 *  Example 'New' Trustcoin contract, code based on multiple sources:
 *
 *  https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20.sol
 *  https://github.com/golemfactory/golem-crowdfunding/tree/master/contracts
 *  https://github.com/ConsenSys/Tokens/blob/master/Token_Contracts/contracts/HumanStandardToken.sol
 */

pragma solidity ^0.4.8;

import './lib/ERC20.sol';
import './lib/SafeMath.sol';
import './Trustcoin.sol';

contract Trustcoin2 is ERC20, SafeMath {

  string public name = 'Trustcoin2';
  uint8 public decimals = 18;
  string public symbol = 'TRST2';
  string public version = 'TRST2.0';
  uint256 public totalSupply; // Begins at 0, but increments as old tokens are migrated (ERC20)
  address public oldToken = '0x123f681646d4a755815f9cb19e1acc8565a0c2ac'; // Address of our old Trustcoin token contract (this is just a random address)
  bool public allowOldMigrations = true; // Is set to false when we finalize migration
  uint256 public allowOldMigrationsUntil = (now + 26 weeks); // Hardcode a timestamp here?

  mapping(address => uint) public balances; // (ERC20)
  mapping (address => mapping (address => uint)) public allowed; // (ERC20)

  // Variables supporting the migration to a new contract (Trustcoin3)
  uint256 public totalMigrated;
  bool public migrationActive;
  address public migrationMaster;
  address public newToken;

  event Discard(address owner, uint256 value);
  event Migrate(address owner, uint256 value);
  event MigrationFinalized();

  modifier onlyFromMigrationMaster() {
    if (msg.sender != migrationMaster) throw;
    _;
  }

  function Trustcoin2(address _migrationMaster) {
    if (_migrationMaster == 0) throw;
    migrationMaster = _migrationMaster;
  }

  /**
   *  (ERC20)
   *  Transfers a specified balance from one address to another
   *  @param {address} _to Address to which tokens should go
   *  @param {uint} _value Number of tokens to transfer
   *  @return {bool} success Whether the transfer was successful
   */
  function transfer(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   *  (ERC20)
   *  Allows contracts to send tokens on our behalf
   *  @param {address} _from Address from which to transfer tokens
   *  @param {address} _to Address to which tokens are to be transferred
   *  @param {uint} _value Number of tokens to transfer
   *  @return {bool} success Whether the transfer was successful
   */
  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];
    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   *  (ERC20)
   *  Returns the token balance of any address
   *  @param {address} _owner Address for which to return the balance
   *  @return {uint} balance Balance of the specified address
   */
  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  /**
   *  (ERC20)
   *  Allow an address to control a specified amount of your tokens
   *  @param {address} _spender Address to which control is to be handed
   *  @param {uint} _value Number of tokens to give control over
   *  @return {bool} success Whether the approval was successful
   */
  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   *  (ERC20)
   *  Returns the remaining aprooved allowance for an address relative to the owner
   *  @param {address} _owner Owner of the tokens
   *  @param {address} _spender Spender of the tokens
   *  @return {uint} remaining Number of approved tokens remaining
   */
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  //
  //  Migration methods
  //

  /**
   *  Sets the owner for the migration behaviour
   *  @param {address} _master Address of the migration controller
   */
  function changeMigrationMaster(address _master) onlyFromMigrationMaster external {
    if (_master == 0) throw;
    migrationMaster = _master;
  }

  /**
   *  Sets the address of the new token contract, so we know who to
   *  accept discardTokens() calls from, and enables token migrations
   *  @param {address} _newToken Address of the new Trustcoin contract
   */
  function setNewToken(address _newToken) onlyFromMigrationMaster external {
    if (newToken != 0) throw;
    if (migrationActive) throw;
    migrationActive = true;
    newToken = _newToken;
  }

  /**
   *  Burns the tokens from an address and increments the totalMigrated
   *  by the same value
   *  @param {address} _from Address which holds the tokens
   *  @param {uint256} _value Number of tokens to be migrated
   */
  function discardTokens(address _from, uint256 _value) external {
    if (!migrationActive) throw;
    if (msg.sender != newToken) throw;
    if (_value == 0) throw;
    if (_value > balances[_from]) throw;
    balances[_from] = safeSub(balances[_from], _value);
    totalSupply = safeSub(totalSupply, _value);
    totalMigrated = safeAdd(totalMigrated, _value);
    Discard(_from, _value);
  }

  /**
   *  Migrates the specified token balance from msg.sender in the old contract
   *  to the new contract
   *  @param {uint256} _value Number of tokens to be migrated
   */
  function migrateOldTokens(uint256 _value) external {
    if (!allowOldMigrations) throw;
    if (_value == 0) throw;
    Trustcoin(oldToken).discardTokens(msg.sender, _value);
    totalSupply = safeAdd(totalSupply, _value);
    balances[msg.sender] = safeAdd(balances[msg.sender], _value);
    Migrate(msg.sender, _value);
  }

  /**
   *  Ends the possibility for any more tokens to be migrated from the old contract
   *  to the new one
   */
  function finalizeMigration() onlyFromMigrationMaster external {
    if (!allowOldMigrations) throw;
    if (now < allowOldMigrationsUntil) throw;
    allowOldMigrations = false;
    MigrationFinalized();
  }

}