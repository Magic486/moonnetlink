///|
pub fn align4(value : Int32) -> Int32 raise ProtocolError {
  guard value >= 0 && value <= 2147483644 else {
    raise ProtocolError("alignment length out of range")
  }
  (value + 3) & -4
}

///|
fn bounds(
  data : Bytes,
  offset : Int32,
  count : Int32,
) -> Unit raise ProtocolError {
  guard offset >= 0 &&
    count >= 0 &&
    offset <= data.length() &&
    count <= data.length() - offset else {
    raise ProtocolError("truncated integer at \{offset}")
  }
}

///|
pub fn u16(
  data : Bytes,
  offset : Int32,
  endian~ : Endian = Little,
) -> Int32 raise ProtocolError {
  bounds(data, offset, 2)
  let a = data[offset].to_int()
  let b = data[offset + 1].to_int()
  match endian {
    Little => a | (b << 8)
    Big => (a << 8) | b
  }
}

///|
pub fn u32(
  data : Bytes,
  offset : Int32,
  endian~ : Endian = Little,
) -> UInt32 raise ProtocolError {
  bounds(data, offset, 4)
  let a = data[offset].to_uint()
  let b = data[offset + 1].to_uint()
  let c = data[offset + 2].to_uint()
  let d = data[offset + 3].to_uint()
  match endian {
    Little => a | (b << 8) | (c << 16) | (d << 24)
    Big => (a << 24) | (b << 16) | (c << 8) | d
  }
}

///|
pub fn i32(
  data : Bytes,
  offset : Int32,
  endian~ : Endian = Little,
) -> Int32 raise ProtocolError {
  u32(data, offset, endian~).reinterpret_as_int()
}

///|
pub fn write_u16(
  data : FixedArray[Byte],
  offset : Int32,
  value : Int32,
  endian~ : Endian = Little,
) -> Unit raise ProtocolError {
  guard offset >= 0 && offset <= data.length() && 2 <= data.length() - offset else {
    raise ProtocolError("write out of bounds")
  }
  guard value >= 0 && value <= 65535 else {
    raise ProtocolError("u16 out of range")
  }
  match endian {
    Little => {
      data[offset] = (value & 255).to_byte()
      data[offset + 1] = (value >> 8).to_byte()
    }
    Big => {
      data[offset] = (value >> 8).to_byte()
      data[offset + 1] = (value & 255).to_byte()
    }
  }
}

///|
pub fn write_u32(
  data : FixedArray[Byte],
  offset : Int32,
  value : UInt32,
  endian~ : Endian = Little,
) -> Unit raise ProtocolError {
  guard offset >= 0 && offset <= data.length() && 4 <= data.length() - offset else {
    raise ProtocolError("write out of bounds")
  }
  for i in 0..<4 {
    let shift = match endian {
      Little => i * 8
      Big => (3 - i) * 8
    }
    data[offset + i] = ((value >> shift) & 255U).to_byte()
  }
}

///|
pub fn uint_payload(value : UInt32, endian~ : Endian = Little) -> Bytes {
  let bytes : FixedArray[Byte] = FixedArray::make(4, 0)
  try! write_u32(bytes, 0, value, endian~)
  Bytes::from_array(bytes)
}

///|
/// Copy a bounded byte range; never retain a mutable view of caller input.
pub fn copy_range(
  data : Bytes,
  start : Int32,
  count : Int32,
) -> Bytes raise ProtocolError {
  bounds(data, start, count)
  Bytes::makei(count, i => data[start + i])
}

///|
pub fn string_payload(value : String) -> Bytes {
  @utf8.encode(value) + b"\x00"
}

///|
/// Decode a NUL-terminated UTF-8 field; reject embedded NUL and malformed UTF-8.
pub fn cstring(data : Bytes) -> String raise ProtocolError {
  guard data.length() > 0 && data[data.length() - 1] == 0 else {
    raise ProtocolError("missing string terminator")
  }
  let value = copy_range(data, 0, data.length() - 1)
  for b in value {
    guard b != 0 else { raise ProtocolError("embedded NUL in string") }
  }
  @utf8.decode(value) catch {
    _ => raise ProtocolError("invalid UTF-8 string")
  }
}
