///|
fn ack_with_attrs(
  code : Int32,
  attrs : Array[@wire.Attribute],
  endian : @wire.Endian,
) -> Ack raise @wire.ProtocolError {
  {
    code,
    message: attr_string(attrs, 1),
    bad_offset: attr_uint(attrs, 2, endian),
    attributes: attrs,
  }
}

///|
fn decode_ack(
  message : @wire.Message,
  endian : @wire.Endian,
) -> Ack raise @wire.ProtocolError {
  let data = message.payload
  // nlmsgerr includes errno and the original nlmsghdr.
  guard data.length() >= 20 else {
    raise @wire.ProtocolError("truncated nlmsgerr")
  }
  let code = @wire.i32(data, 0, endian~)
  let original_length = @wire.u32(data, 4, endian~)
  guard original_length >= 16U else {
    raise @wire.ProtocolError("invalid echoed header")
  }
  let capped = (message.header.flags & 0x100) != 0
  let offset = if capped || code == 0 {
    20
  } else {
    guard original_length <= (data.length() - 4).reinterpret_as_uint() else {
      raise @wire.ProtocolError("truncated echoed request")
    }
    4 + @wire.align4(original_length.reinterpret_as_int())
  }
  let attrs = if (message.header.flags & 0x200) != 0 {
    attrs_at(data, offset, endian)
  } else {
    []
  }
  ack_with_attrs(code, attrs, endian)
}

///|
fn decode_done(
  message : @wire.Message,
  endian : @wire.Endian,
) -> Ack raise @wire.ProtocolError {
  if message.payload.length() == 0 {
    return { code: 0, message: None, bad_offset: None, attributes: [], }
  }
  let code = @wire.i32(message.payload, 0, endian~)
  let attrs = if (message.header.flags & 0x200) != 0 {
    attrs_at(message.payload, 4, endian)
  } else {
    []
  }
  ack_with_attrs(code, attrs, endian)
}

///|
/// Read-only dump request. Never emits network mutation operations.
pub fn request(kind : ObjectKind, sequence : UInt32) -> @wire.Message {
  let (message_type, size) = match kind {
    Links => (18, 16)
    Addresses => (22, 8)
    Routes => (26, 12)
    Neighbors => (30, 12)
  }
  {
    header: { kind: message_type, flags: 0x301, sequence, port: 0U, },
    payload: Bytes::make(size, 0),
  }
}
