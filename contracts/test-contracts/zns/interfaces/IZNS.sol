// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IZNS {
  // Logged when a node has new owner
  // Note that node is a namehash of a specified node, label is a namehash of subnode.
  event NewOwner(bytes32 indexed node, address owner);

  // Logged when the L2 owner of a node transfers ownership to a new L2 account.
  event NewPubKey(bytes32 indexed node, bytes32 pubKeyX, bytes32 pubKeyY);

  // Logged when the resolver for a node changes.
  event NewResolver(bytes32 indexed node, address resolver);

  event TLDAdded(bytes32 indexed node);

  function setSubnodeRecord(
    bytes32 _node,
    bytes32 _label,
    address _owner,
    bytes32 _pubKeyX,
    bytes32 _pubKeyY,
    address _resolver
  ) external returns (bytes32, uint32);

  function setSubnodeOwner(
    bytes32 _node,
    bytes32 _label,
    address _owner,
    bytes32 _pubKeyX,
    bytes32 _pubKeyY
  ) external returns (bytes32);

  function setResolver(bytes32 _node, address _resolver) external;

  function resolver(bytes32 node) external view returns (address);

  function owner(bytes32 node) external view returns (address);

  function pubKey(bytes32 node) external view returns (bytes32, bytes32);

  function accountIndex(bytes32 node) external view returns (uint32);

  function recordExists(bytes32 node) external view returns (bool);

  function subNodeRecordExists(bytes32 node, bytes32 label) external view returns (bool);
}
