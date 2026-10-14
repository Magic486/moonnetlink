///|
fn message(payload : Bytes) -> @wire.Message {
  { header: { kind: 16, flags: 0, sequence: 42U, port: 77U, }, payload, }
}

///|
fn base_attrs() -> Array[@wire.Attribute] {
  [
    { raw_kind: 1, payload: b"\x10\x00", },
    { raw_kind: 2, payload: @wire.string_payload("nlctrl"), },
  ]
}

///|
fn with_attrs(
  attrs : Array[@wire.Attribute],
) -> @wire.Message raise @wire.ProtocolError {
  message(
    @genl.encode({
      command: 1,
      version: 2,
      reserved: 0,
      user_header: b"",
      attributes: attrs,
    }),
  )
}

///|
test "independent controller golden decodes missing optional metadata as None" {
  let family = @genl.decode_family(
    message(
      b"\x01\x02\x00\x00\x06\x00\x01\x00\x10\x00\x00\x00\x0b\x00\x02\x00nlctrl\x00\x00\x08\x00\x03\x00\x02\x00\x00\x00",
    ),
  )
  assert_eq(family.id, 16)
  assert_eq(family.name, "nlctrl")
  assert_eq(family.version, Some(2U))
  assert_eq(family.header_size, None)
  assert_eq(family.operations.length(), 0)
}

///|
test "independent big endian controller golden" {
  let family = @genl.decode_family(
    message(
      b"\x01\x02\x00\x00\x00\x06\x00\x01\x00\x10\x00\x00\x00\x0b\x00\x02nlctrl\x00\x00\x00\x08\x00\x03\x00\x00\x00\x02",
    ),
    endian=@wire.Big,
  )
  assert_eq(family.id, 16)
  assert_eq(family.version, Some(2U))
}

///|
test "envelope roundtrips a padded user header and opaque attributes in both endians" {
  let original : @genl.Envelope = {
    command: 255,
    version: 3,
    reserved: 0xbeef,
    user_header: b"XYZ",
    attributes: [{ raw_kind: 0x802a, payload: b"\x04\x00\x01\x00", }],
  }
  for endian in [@wire.Little, @wire.Big] {
    let encoded = @genl.encode(original, endian~)
    assert_eq(encoded[7], 0)
    assert_eq(@genl.decode(encoded, user_header_size=3, endian~), original)
  }
}

///|
test "envelope rejects short fixed header invalid user size and missing alignment" {
  for length in 0..<4 {
    try @genl.decode(Bytes::make(length, 0)) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("short header accepted")
    }
  }
  for size in [-1, 1, 0x7fffffff] {
    try @genl.decode(b"\x01\x02\x00\x00", user_header_size=size) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("invalid size accepted")
    }
  }
  try @genl.decode(b"\x01\x02\x00\x00XYZ", user_header_size=3) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("missing padding accepted")
  }
}

///|
test "controller indexed arrays accept legacy nests and preserve unknown TLVs" {
  let attrs = base_attrs()
  let operation = @wire.encode_attributes([
    { raw_kind: 1, payload: @wire.uint_payload(3U), },
    { raw_kind: 2, payload: @wire.uint_payload(6U), },
    { raw_kind: 99, payload: b"op", },
  ])
  let group = @wire.encode_attributes([
    { raw_kind: 1, payload: @wire.string_payload("notify"), },
    { raw_kind: 2, payload: @wire.uint_payload(16U), },
  ])
  attrs.push({
    raw_kind: 6,
    payload: @wire.encode_attributes([{ raw_kind: 1, payload: operation, }]),
  })
  attrs.push({
    raw_kind: 0x8007,
    payload: @wire.encode_attributes([{ raw_kind: 0x8001, payload: group, }]),
  })
  attrs.push({ raw_kind: 99, payload: b"future", })
  let family = @genl.decode_family(with_attrs(attrs))
  assert_eq(family.operations[0].id, 3U)
  assert_eq(family.operations[0].flags, 6U)
  assert_eq(family.operations[0].attributes[2].payload, b"op")
  assert_eq(family.groups[0].name, "notify")
  assert_eq(family.groups[0].id, 16U)
  assert_eq(family.attributes[4].payload, b"future")
}

///|
test "ambiguous missing and malformed mandatory controller fields fail" {
  let cases : Array[Array[@wire.Attribute]] = [
    [],
    [{ raw_kind: 1, payload: b"\x10\x00", }],
    [{ raw_kind: 1, payload: b"\x10", }, { raw_kind: 2, payload: b"x\x00", }],
    [
      { raw_kind: 1, payload: b"\x00\x00", },
      { raw_kind: 2, payload: b"x\x00", },
    ],
    [{ raw_kind: 1, payload: b"\x10\x00", }, { raw_kind: 2, payload: b"\x00", }],
    [
      { raw_kind: 1, payload: b"\x10\x00", },
      { raw_kind: 1, payload: b"\x11\x00", },
      { raw_kind: 2, payload: b"x\x00", },
    ],
  ]
  for attrs in cases {
    try @genl.decode_family(with_attrs(attrs)) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("bad metadata accepted")
    }
  }
}

///|
test "controller optional u32 validates width and network byte order" {
  let attrs = base_attrs()
  attrs.push({ raw_kind: 0x4003, payload: b"\x00\x00\x00\x07", })
  assert_eq(@genl.decode_family(with_attrs(attrs)).version, Some(7U))
  let broken = base_attrs()
  broken.push({ raw_kind: 3, payload: b"\x01", })
  try @genl.decode_family(with_attrs(broken)) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("short u32 accepted")
  }
}

///|
test "family request uses controller GET command ACK and original sequence" {
  let request = @genl.family_request("nlctrl", 123U)
  assert_eq(request.header.kind, 16)
  assert_eq(request.header.flags, 5)
  assert_eq(request.header.sequence, 123U)
  let envelope = @genl.decode(request.payload)
  assert_eq(envelope.command, 3)
  assert_eq(envelope.version, 2)
  assert_eq(@wire.cstring(envelope.attributes[0].payload), "nlctrl")
  for name in ["", "abcdefghijklmnop", "bad\u0000name", "界界界界界界"] {
    try @genl.family_request(name, 1U) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("invalid name accepted")
    }
  }
}

///|
test "controller rejects wrong family or nonmetadata command" {
  let valid = with_attrs(base_attrs())
  try
    @genl.decode_family({ ..valid, header: { ..valid.header, kind: 17, }, })
  catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("wrong family accepted")
  }
  let wrong = @genl.encode({
    command: 10,
    version: 2,
    reserved: 0,
    user_header: b"",
    attributes: base_attrs(),
  })
  try @genl.decode_family(message(wrong)) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("policy reply accepted as metadata")
  }
}
