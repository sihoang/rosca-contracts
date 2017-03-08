pragma solidity ^0.4.8;

contract MigratableToken {

  uint256 public totalMigrated; // Begins at 0 and increments if tokens are migrated to a new contract
  address public newToken; // Address of the new token contract
  address public migrationMaster;

  event OutgoingMigration(address owner, uint256 value);

  modifier onlyFromMigrationMaster() {
    if (msg.sender != migrationMaster) throw;
    _;
  }

  //
  //  Migration methods
  //

  /**
   *  Changes the owner for the migration behaviour
   *  @param _master Address of the new migration controller
   */
  function changeMigrationMaster(address _master) onlyFromMigrationMaster external {
    if (_master == 0) throw;
    migrationMaster = _master;
  }

  /**
   *  Sets the address of the new token contract, so we know who to
   *  accept discardTokens() calls from, and enables token migrations
   *  @param _newToken Address of the new Trustcoin contract
   */
  function setNewTokenAddress(address _newToken) onlyFromMigrationMaster external {
    if (newToken != 0) throw; // Ensure we haven't already set the new token
    if (_newToken == 0) throw; // Paramater validation
    newToken = _newToken;
  }
  
}