///|
/// Decode one complete datagram. Netlink is not a byte stream.
pub fn decode(
  data : Bytes,
  endian~ : Endian = Little,
) -> Array[Message] raise ProtocolError {
  let result : Array[Message] = []
  let mut offset = 0
  while offset < data.length() {
    bounds(data, offset, 16)
    let length = u32(data, offset, endian~)
    guard length >= 16U &&
      length <= (data.length() - offset).reinterpret_as_uint() else {
      raise ProtocolError("invalid message length at \{offset}")
    }
    let size = length.reinterpret_as_int()
    result.push({
      header: {
        kind: u16(data, offset + 4, endian~),
        flags: u16(data, offset + 6, endian~),
        sequence: u32(data, offset + 8, endian~),
        port: u32(data, offset + 12, endian~),
      },
      payload: copy_range(data, offset + 16, size - 16),
    })
    let aligned = align4(size)
    if size == data.length() - offset {
      break
    }
    guard aligned <= data.length() - offset else {
      raise ProtocolError("incomplete message padding")
    }
    offset += aligned
  }
  result
}

///|
pub fn encode(
  message : Message,
  endian~ : Endian = Little,
) -> Bytes raise ProtocolError {
  guard message.payload.length() <= 16777216 else {
    raise ProtocolError("message exceeds 16 MiB encoding limit")
  }
  let size = 16 + message.payload.length()
  let data : FixedArray[Byte] = FixedArray::make(align4(size), 0)
  write_u32(data, 0, size.reinterpret_as_uint(), endian~)
  write_u16(data, 4, message.header.kind, endian~)
  write_u16(data, 6, message.header.flags, endian~)
  write_u32(data, 8, message.header.sequence, endian~)
  write_u32(data, 12, message.header.port, endian~)
  for i, b in message.payload {
    data[16 + i] = b
  }
  Bytes::from_array(data)
}

///|
pub fn decode_attributes(
  data : Bytes,
  endian~ : Endian = Little,
) -> Array[Attribute] raise ProtocolError {
  let result : Array[Attribute] = []
  let mut offset = 0
  while offset < data.length() {
    bounds(data, offset, 4)
    let size = u16(data, offset, endian~)
    guard size >= 4 && size <= data.length() - offset else {
      raise ProtocolError("invalid attribute length at \{offset}")
    }
    result.push({
      raw_kind: u16(data, offset + 2, endian~),
      payload: copy_range(data, offset + 4, size - 4),
    })
    let aligned = align4(size)
    if size == data.length() - offset {
      break
    }
    guard aligned <= data.length() - offset else {
      raise ProtocolError("incomplete attribute padding")
    }
    offset += aligned
  }
  result
}

///|
pub fn encode_attributes(
  attributes : Array[Attribute],
  endian~ : Endian = Little,
) -> Bytes raise ProtocolError {
  let mut result = b""
  for attribute in attributes {
    guard attribute.payload.length() <= 65531 else {
      raise ProtocolError("attribute exceeds u16 length")
    }
    let size = 4 + attribute.payload.length()
    let data : FixedArray[Byte] = FixedArray::make(align4(size), 0)
    write_u16(data, 0, size, endian~)
    write_u16(data, 2, attribute.raw_kind, endian~)
    for i, b in attribute.payload {
      data[4 + i] = b
    }
    result = result + Bytes::from_array(data)
  }
  result
}

///|
pub fn find_attribute(
  attributes : Array[Attribute],
  kind : Int32,
) -> Attribute? {
  for a in attributes {
    if a.kind() == kind {
      return Some(a)
    }
  }
  None
}
