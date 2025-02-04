// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @title ZkBNBOwnable Contract
/// @author ZkBNB Team
contract ZkBNBOwnable {
  /// @dev Storage position of the masters address (keccak256('eip1967.proxy.admin') - 1)
  bytes32 private constant MASTER_POSITION = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  /**
   * @dev Emitted when the admin account has changed.
   */
  event AdminChanged(address previousAdmin, address newAdmin);

  /// @notice Contract constructor
  /// @dev Sets msg sender address as masters address
  /// @param masterAddress Master address
  constructor(address masterAddress) {
    setMaster(masterAddress);
  }

  modifier onlyMaster() {
    require(msg.sender == getMaster(), "1c");
    // oro11 - only by master
    _;
  }

  /// @notice Transfer mastership of the contract to new master
  /// @param _newMaster New masters address
  function transferMastership(address _newMaster) external onlyMaster {
    require(_newMaster != address(0), "1d");

    address _oldMaster = getMaster();

    // otp11 - new masters address can't be zero address
    setMaster(_newMaster);

    emit AdminChanged(_oldMaster, _newMaster);
  }

  /// @notice Returns contract masters address
  /// @return master Master's address
  function getMaster() public view returns (address master) {
    bytes32 position = MASTER_POSITION;
    assembly {
      master := sload(position)
    }
  }

  /// @dev Sets new masters address
  /// @param _newMaster New master's address
  function setMaster(address _newMaster) internal {
    bytes32 position = MASTER_POSITION;
    assembly {
      sstore(position, _newMaster)
    }
  }
}
