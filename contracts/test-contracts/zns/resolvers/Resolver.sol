//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./profile/INameResolver.sol";
import "./ISupportsInterface.sol";
import "./profile/IABIResolver.sol";
import "./profile/IAddrResolver.sol";
import "./profile/IPubKeyResolver.sol";
import "./profile/IZkBNBPubKeyResolver.sol";

/**
 * A generic resolver interface which includes all the functions including the ones deprecated
 */
interface Resolver is
  ISupportsInterface,
  IABIResolver,
  IAddrResolver,
  IZkBNBPubKeyResolver,
  IPubKeyResolver,
  INameResolver
{
  function setABI(bytes32 node, uint256 contentType, bytes calldata data) external;

  function setAddr(bytes32 node, address addr) external;

  function setName(bytes32 node, string calldata _name) external;

  function setPubKey(bytes32 node, bytes32 x, bytes32 y) external;

  // not support yet
  //    function setZkBNBPubKey(
  //        bytes32 node,
  //        bytes32 zkbnbPubKey
  //    ) external;

  function multicall(bytes[] calldata data) external returns (bytes[] memory results);
}
