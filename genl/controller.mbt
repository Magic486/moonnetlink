///|
fn unique(
  attrs : Array[@wire.Attribute],
  kind : Int32,
) -> @wire.Attribute? raise @wire.ProtocolError {
  let mut result = None
  for attr in attrs {
    if attr.kind() == kind {
      guard result is None else {
        raise @wire.ProtocolError("duplicate controller attribute \{kind}")
      }
      result = Some(attr)
    }
  }
  result
}

///|
fn required(
  attrs : Array[@wire.Attribute],
  kind : Int32,
) -> @wire.Attribute raise @wire.ProtocolError {
  match unique(attrs, kind) {
    Some(attr) => attr
    None => raise @wire.ProtocolError("missing controller attribute \{kind}")
  }
}

///|
fn integer(
  attr : @wire.Attribute,
  endian : @wire.Endian,
) -> UInt32 raise @wire.ProtocolError {
  guard attr.payload.length() == 4 else {
    raise @wire.ProtocolError("controller attribute requires u32")
  }
  @wire.u32(
    attr.payload,
    0,
    endian=if attr.network_order() { @wire.Big } else { endian },
  )
}

///|
fn optional_integer(
  attrs : Array[@wire.Attribute],
  kind : Int32,
  endian : @wire.Endian,
) -> UInt32? raise @wire.ProtocolError {
  unique(attrs, kind).map(attr => integer(attr, endian))
}

///|
fn indexed(
  attrs : Array[@wire.Attribute],
  kind : Int32,
  endian : @wire.Endian,
) -> Array[Array[@wire.Attribute]] raise @wire.ProtocolError {
  match unique(attrs, kind) {
    None => []
    Some(container) =>
      @wire.decode_attributes(container.payload, endian~).map(entry => {
        @wire.decode_attributes(entry.payload, endian~)
      })
  }
}

///|
pub fn decode_family(
  message : @wire.Message,
  endian~ : @wire.Endian = @wire.Little,
) -> Family raise @wire.ProtocolError {
  guard message.header.kind == 16 else {
    raise @wire.ProtocolError("not a Generic Netlink controller reply")
  }
  let envelope = decode(message.payload, endian~)
  guard envelope.command == 1 || envelope.command == 3 else {
    raise @wire.ProtocolError("not a family metadata reply")
  }
  let attrs = envelope.attributes
  let id_attr = required(attrs, 1)
  guard id_attr.payload.length() == 2 else {
    raise @wire.ProtocolError("family id requires u16")
  }
  let id = @wire.u16(
    id_attr.payload,
    0,
    endian=if id_attr.network_order() { @wire.Big } else { endian },
  )
  guard id >= 16 else {
    raise @wire.ProtocolError("reserved Generic Netlink family id")
  }
  let name = @wire.cstring(required(attrs, 2).payload)
  guard name.length() > 0 else {
    raise @wire.ProtocolError("empty family name")
  }
  let operations = indexed(attrs, 6, endian).map(fields => {
    let operation : Operation = {
      id: integer(required(fields, 1), endian),
      flags: integer(required(fields, 2), endian),
      attributes: fields,
    }
    operation
  })
  let groups = indexed(attrs, 7, endian).map(fields => {
    let group : Group = {
      id: integer(required(fields, 2), endian),
      name: @wire.cstring(required(fields, 1).payload),
      attributes: fields,
    }
    group
  })
  {
    id,
    name,
    version: optional_integer(attrs, 3, endian),
    header_size: optional_integer(attrs, 4, endian),
    max_attribute: optional_integer(attrs, 5, endian),
    operations,
    groups,
    attributes: attrs,
  }
}

///|
/// Read-only CTRL_CMD_GETFAMILY with REQUEST|ACK. Names fit Linux GENL_NAMSIZ.
pub fn family_request(
  name : String,
  sequence : UInt32,
  endian~ : @wire.Endian = @wire.Little,
) -> @wire.Message raise @wire.ProtocolError {
  let payload = @wire.string_payload(name)
  guard payload.length() > 1 && payload.length() <= 16 else {
    raise @wire.ProtocolError("family name must contain 1..15 UTF-8 bytes")
  }
  ignore(@wire.cstring(payload))
  {
    header: { kind: 16, flags: 5, sequence, port: 0U, },
    payload: encode(
      {
        command: 3,
        version: 2,
        reserved: 0,
        user_header: b"",
        attributes: [{ raw_kind: 2, payload, }],
      },
      endian~,
    ),
  }
}
