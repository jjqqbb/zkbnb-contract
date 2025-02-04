// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

// Functions named bytesToX, except bytesToBytes20, where X is some type of size N < 32 (size of one word)
// implements the following algorithm:
// f(bytes memory input, uint offset) -> X out
// where byte representation of out is N bytes from input at the given offset
// 1) We compute memory location of the word W such that last N bytes of W is input[offset..offset+N]
// W_address = input + 32 (skip stored length of bytes) + offset - (32 - N) == input + offset + N
// 2) We load W from memory into out, last N bytes of W are placed into out

library Bytes {
  bytes16 private constant _SYMBOLS = "0123456789abcdef";

  /**
   * @dev Converts a `bytes32` to its ASCII `string` hexadecimal representation with fixed length.
   */
  function bytes32ToHexString(bytes32 bytesValue, bool prefix) internal pure returns (string memory) {
    uint256 uint256Value = uint256(bytesValue);
    uint skip;
    bytes memory buffer;
    if (prefix) {
      skip = 2;
      buffer = new bytes(66);
      buffer[0] = "0";
      buffer[1] = "x";
    } else {
      skip = 0;
      buffer = new bytes(64);
    }
    for (uint256 i = 65; i > 1; --i) {
      buffer[i + skip - 2] = _SYMBOLS[uint256Value & 0xf];
      uint256Value >>= 4;
    }
    require(uint256Value == 0, "Strings: hex length insufficient");
    return string(buffer);
  }

  function toBytesFromUInt16(uint16 self) internal pure returns (bytes memory _bts) {
    return toBytesFromUIntTruncated(uint256(self), 2);
  }

  function toBytesFromUInt24(uint24 self) internal pure returns (bytes memory _bts) {
    return toBytesFromUIntTruncated(uint256(self), 3);
  }

  function toBytesFromUInt32(uint32 self) internal pure returns (bytes memory _bts) {
    return toBytesFromUIntTruncated(uint256(self), 4);
  }

  function toBytesFromUInt128(uint128 self) internal pure returns (bytes memory _bts) {
    return toBytesFromUIntTruncated(uint256(self), 16);
  }

  // Copies 'self' into a new 'bytes memory'.
  // Returns the newly created 'bytes memory'. The returned bytes will be of length '20'.
  function toBytesFromAddress(address self) internal pure returns (bytes memory bts) {
    bts = toBytesFromUIntTruncated(uint256(uint160(self)), 20);
  }

  // See comment at the top of this file for explanation of how this function works.
  // NOTE: theoretically possible overflow of (_start + 20)
  function bytesToAddress(bytes memory self, uint256 _start) internal pure returns (address addr) {
    uint256 offset = _start + 20;
    require(self.length >= offset, "R");
    assembly {
      addr := mload(add(self, offset))
    }
  }

  // Reasoning about why this function works is similar to that of other similar functions, except NOTE below.
  // NOTE: that bytes1..32 is stored in the beginning of the word unlike other primitive types
  // NOTE: theoretically possible overflow of (_start + 20)
  function bytesToBytes20(bytes memory self, uint256 _start) internal pure returns (bytes20 r) {
    require(self.length >= (_start + 20), "S");
    assembly {
      r := mload(add(add(self, 0x20), _start))
    }
  }

  // See comment at the top of this file for explanation of how this function works.
  // NOTE: theoretically possible overflow of (_start + 0x2)
  function bytesToUInt16(bytes memory _bytes, uint256 _start) internal pure returns (uint16 r) {
    uint256 offset = _start + 0x2;
    require(_bytes.length >= offset, "T");
    assembly {
      r := mload(add(_bytes, offset))
    }
  }

  // See comment at the top of this file for explanation of how this function works.
  // NOTE: theoretically possible overflow of (_start + 0x3)
  function bytesToUInt24(bytes memory _bytes, uint256 _start) internal pure returns (uint24 r) {
    uint256 offset = _start + 0x3;
    require(_bytes.length >= offset, "U");
    assembly {
      r := mload(add(_bytes, offset))
    }
  }

  // NOTE: theoretically possible overflow of (_start + 0x4)
  function bytesToUInt32(bytes memory _bytes, uint256 _start) internal pure returns (uint32 r) {
    uint256 offset = _start + 0x4;
    require(_bytes.length >= offset, "V");
    assembly {
      r := mload(add(_bytes, offset))
    }
  }

  // NOTE: theoretically possible overflow of (_start + 0x5)
  function bytesToUInt40(bytes memory _bytes, uint256 _start) internal pure returns (uint40 r) {
    uint256 offset = _start + 0x5;
    require(_bytes.length >= offset, "V");
    assembly {
      r := mload(add(_bytes, offset))
    }
  }

  // NOTE: theoretically possible overflow of (_start + 0x10)
  function bytesToUInt128(bytes memory _bytes, uint256 _start) internal pure returns (uint128 r) {
    uint256 offset = _start + 0x10;
    require(_bytes.length >= offset, "W");
    assembly {
      r := mload(add(_bytes, offset))
    }
  }

  // See comment at the top of this file for explanation of how this function works.
  // NOTE: theoretically possible overflow of (_start + 0x14)
  function bytesToUInt160(bytes memory _bytes, uint256 _start) internal pure returns (uint160 r) {
    uint256 offset = _start + 0x14;
    require(_bytes.length >= offset, "X");
    assembly {
      r := mload(add(_bytes, offset))
    }
  }

  // NOTE: theoretically possible overflow of (_start + 0x10)
  function bytesToUInt256(bytes memory _bytes, uint256 _start) internal pure returns (uint256 r) {
    uint256 offset = _start + 0x20;
    require(_bytes.length >= offset, "W");
    assembly {
      r := mload(add(_bytes, offset))
    }
  }

  // NOTE: theoretically possible overflow of (_start + 0x20)
  function bytesToBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32 r) {
    uint256 offset = _start + 0x20;
    require(_bytes.length >= offset, "Y");
    assembly {
      r := mload(add(_bytes, offset))
    }
  }

  // Original source code: https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol#L228
  // Get slice from bytes arrays
  // Returns the newly created 'bytes memory'
  // NOTE: theoretically possible overflow of (_start + _length)
  function slice(bytes memory _bytes, uint256 _start, uint256 _length) internal pure returns (bytes memory) {
    require(_length + 31 >= _length, "1B");
    require(_bytes.length >= _start + _length, "1S");

    bytes memory tempBytes;

    assembly {
      switch iszero(_length)
      case 0 {
        // Get a location of some free memory and store it in tempBytes as
        // Solidity does for memory variables.
        tempBytes := mload(0x40)

        // The first word of the slice result is potentially a partial
        // word read from the original array. To read it, we calculate
        // the length of that partial word and start copying that many
        // bytes into the array. The first word we copy will start with
        // data we don't care about, but the last `lengthmod` bytes will
        // land at the beginning of the contents of the new array. When
        // we're done copying, we overwrite the full first word with
        // the actual length of the slice.
        let lengthmod := and(_length, 31)

        // The multiplication in the next line is necessary
        // because when slicing multiples of 32 bytes (lengthmod == 0)
        // the following copy loop was copying the origin's length
        // and then ending prematurely not copying everything it should.
        let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
        let end := add(mc, _length)

        for {
          // The multiplication in the next line has the same exact purpose
          // as the one above.
          let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
        } lt(mc, end) {
          mc := add(mc, 0x20)
          cc := add(cc, 0x20)
        } {
          mstore(mc, mload(cc))
        }

        mstore(tempBytes, _length)

        //update free-memory pointer
        //allocating the array padded to 32 bytes like the compiler does now
        mstore(0x40, and(add(mc, 31), not(31)))
      }
      //if we want a zero-length slice let's just return a zero-length array
      default {
        tempBytes := mload(0x40)
        //zero out the 32 bytes slice we are about to return
        //we need to do it because Solidity does not garbage collect
        mstore(tempBytes, 0)

        mstore(0x40, add(tempBytes, 0x20))
      }
    }

    return tempBytes;
  }

  /// Reads byte stream
  /// @return newOffset - offset + amount of bytes read
  /// @return data - actually read data
  // NOTE: theoretically possible overflow of (_offset + _length)
  function read(
    bytes memory _data,
    uint256 _offset,
    uint256 _length
  ) internal pure returns (uint256 newOffset, bytes memory data) {
    data = slice(_data, _offset, _length);
    newOffset = _offset + _length;
  }

  // NOTE: theoretically possible overflow of (_offset + 1)
  function readBool(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, bool r) {
    newOffset = _offset + 1;
    r = uint8(_data[_offset]) != 0;
  }

  // NOTE: theoretically possible overflow of (_offset + 1)
  function readUInt8(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint8 r) {
    newOffset = _offset + 1;
    r = uint8(_data[_offset]);
  }

  // NOTE: theoretically possible overflow of (_offset + 2)
  function readUInt16(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint16 r) {
    newOffset = _offset + 2;
    r = bytesToUInt16(_data, _offset);
  }

  // NOTE: theoretically possible overflow of (_offset + 3)
  function readUInt24(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint24 r) {
    newOffset = _offset + 3;
    r = bytesToUInt24(_data, _offset);
  }

  // NOTE: theoretically possible overflow of (_offset + 4)
  function readUInt32(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint32 r) {
    newOffset = _offset + 4;
    r = bytesToUInt32(_data, _offset);
  }

  // NOTE: theoretically possible overflow of (_offset + 5)
  function readUInt40(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint40 r) {
    newOffset = _offset + 5;
    r = bytesToUInt40(_data, _offset);
  }

  // NOTE: theoretically possible overflow of (_offset + 16)
  function readUInt128(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint128 r) {
    newOffset = _offset + 16;
    r = bytesToUInt128(_data, _offset);
  }

  // NOTE: theoretically possible overflow of (_offset + 16)
  function readUInt256(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint256 r) {
    newOffset = _offset + 32;
    r = bytesToUInt256(_data, _offset);
  }

  // NOTE: theoretically possible overflow of (_offset + 20)
  function readUInt160(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint160 r) {
    newOffset = _offset + 20;
    r = bytesToUInt160(_data, _offset);
  }

  // NOTE: theoretically possible overflow of (_offset + 20)
  function readAddress(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, address r) {
    newOffset = _offset + 20;
    r = bytesToAddress(_data, _offset);
  }

  // NOTE: theoretically possible overflow of (_offset + 20)
  function readBytes20(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, bytes20 r) {
    newOffset = _offset + 20;
    r = bytesToBytes20(_data, _offset);
  }

  // NOTE: theoretically possible overflow of (_offset + 32)
  function readBytes32(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, bytes32 r) {
    newOffset = _offset + 32;
    r = bytesToBytes32(_data, _offset);
  }

  /// Trim bytes into single word
  function trim(bytes memory _data, uint256 _newLength) internal pure returns (uint256 r) {
    require(_newLength <= 0x20, "10");
    // new_length is longer than word
    require(_data.length >= _newLength, "11");
    // data is to short

    uint256 a;
    assembly {
      a := mload(add(_data, 0x20)) // load bytes into uint256
    }

    return a >> ((0x20 - _newLength) * 8);
  }

  // Helper function for hex conversion.
  function halfByteToHex(bytes1 _byte) internal pure returns (bytes1 _hexByte) {
    require(uint8(_byte) < 0x10, "hbh11");
    // half byte's value is out of 0..15 range.

    // "FEDCBA9876543210" ASCII-encoded, shifted and automatically truncated.
    return bytes1(uint8(0x66656463626139383736353433323130 >> (uint8(_byte) * 8)));
  }

  // Convert bytes to ASCII hex representation
  function bytesToHexASCIIBytes(bytes memory _input) internal pure returns (bytes memory _output) {
    bytes memory outStringBytes = new bytes(_input.length * 2);

    // code in `assembly` construction is equivalent of the next code:
    // for (uint i = 0; i < _input.length; ++i) {
    //     outStringBytes[i*2] = halfByteToHex(_input[i] >> 4);
    //     outStringBytes[i*2+1] = halfByteToHex(_input[i] & 0x0f);
    // }
    assembly {
      let input_curr := add(_input, 0x20)
      let input_end := add(input_curr, mload(_input))

      for {
        let out_curr := add(outStringBytes, 0x20)
      } lt(input_curr, input_end) {
        input_curr := add(input_curr, 0x01)
        out_curr := add(out_curr, 0x02)
      } {
        let curr_input_byte := shr(0xf8, mload(input_curr))
        // here outStringByte from each half of input byte calculates by the next:
        //
        // "FEDCBA9876543210" ASCII-encoded, shifted and automatically truncated.
        // outStringByte = byte (uint8 (0x66656463626139383736353433323130 >> (uint8 (_byteHalf) * 8)))
        mstore(out_curr, shl(0xf8, shr(mul(shr(0x04, curr_input_byte), 0x08), 0x66656463626139383736353433323130)))
        mstore(
          add(out_curr, 0x01),
          shl(0xf8, shr(mul(and(0x0f, curr_input_byte), 0x08), 0x66656463626139383736353433323130))
        )
      }
    }
    return outStringBytes;
  }

  // Copies 'len' lower bytes from 'self' into a new 'bytes memory'.
  // Returns the newly created 'bytes memory'. The returned bytes will be of length 'len'.
  function toBytesFromUIntTruncated(uint256 self, uint8 byteLength) private pure returns (bytes memory bts) {
    require(byteLength <= 32, "Q");
    bts = new bytes(byteLength);
    // Even though the bytes will allocate a full word, we don't want
    // any potential garbage bytes in there.
    uint256 data = self << ((32 - byteLength) * 8);
    assembly {
      mstore(
        add(bts, 32), // BYTES_HEADER_SIZE
        data
      )
    }
  }
}
