pragma solidity ^0.4.8;

contract MigratedToken {
  address public constant oldToken = 0x6651fdb9d5d15ca55cc534ee5fa6c3432acdf15b; // Address of our old Trustcoin token contract (this is just a random address)
  bool public allowOldMigrations = true; // Is set to false when we finalize migration
  uint256 public allowOldMigrationsUntil;
  address public migrationMaster;

  event IncomingMigration(address owner, uint256 value);
  event MigrationFinalized();

  function migrateOldTokens(uint256 _value) external;

  modifier onlyFromMigrationMaster() {
    if (msg.sender != migrationMaster) throw;
    _;
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