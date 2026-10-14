///|
fn bad_message(data : Bytes) -> Unit raise {
  try @wire.decode(data) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("expected rejected message")
  }
}

///|
fn bad_attribute(data : Bytes) -> Unit raise {
  try @wire.decode_attributes(data) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("expected rejected attribute")
  }
}

///|
test "independent nlmsghdr golden little endian" {
  let result = @wire.decode(
    b"\x14\x00\x00\x00\x03\x00\x02\x00\x78\x56\x34\x12\xff\xff\xff\xff\x00\x00\x00\x00",
  )
  assert_eq(result.length(), 1)
  assert_eq(result[0].header.sequence, 0x12345678U)
  assert_eq(result[0].header.port, 0xffffffffU)
  assert_eq(result[0].header.kind, 3)
  assert_eq(result[0].header.flags, 2)
  assert_eq(result[0].payload, b"\x00\x00\x00\x00")
}

///|
test "independent big endian golden" {
  let result = @wire.decode(
    b"\x00\x00\x00\x10\x00\x10\x03\x01\x12\x34\x56\x78\x00\x00\x00\x00",
    endian=@wire.Big,
  )
  assert_eq(result[0].header.sequence, 0x12345678U)
  assert_eq(result[0].header.kind, 16)
  assert_eq(result[0].header.flags, 0x301)
}

///|
test "message round trip both byte orders and alignment boundaries" {
  for order in [@wire.Little, @wire.Big] {
    for size in 0..<65 {
      let message : @wire.Message = {
        header: {
          kind: 65535,
          flags: 0xffff,
          sequence: 0xffffffffU,
          port: 0x80000000U,
        },
        payload: Bytes::makei(size, i => (i & 255).to_byte()),
      }
      let encoded = @wire.encode(message, endian=order)
      assert_eq(encoded.length() % 4, 0)
      assert_eq(@wire.decode(encoded, endian=order), [message])
    }
  }
}

///|
test "every nonempty truncation before declared end is rejected" {
  let message : @wire.Message = {
    header: { kind: 17, flags: 0, sequence: 1U, port: 0U, },
    payload: b"abcdefghijkl",
  }
  let bytes = @wire.encode(message)
  for n in 1..<bytes.length() {
    bad_message(@wire.copy_range(bytes, 0, n))
  }
  assert_eq(@wire.decode(b"").length(), 0)
}

///|
test "zero and uint32 overflow message lengths never wrap" {
  for size in [0U, 1U, 15U, 17U, 0x7fffffffU, 0x80000000U, 0xffffffffU] {
    bad_message(@wire.uint_payload(size) + Bytes::make(12, 0))
  }
}

///|
test "multiple messages and final unpadded message" {
  let m : @wire.Message = {
    header: { kind: 100, flags: 0, sequence: 1U, port: 0U, },
    payload: b"x",
  }
  let encoded = @wire.encode(m)
  assert_eq(@wire.decode(encoded + @wire.copy_range(encoded, 0, 17)), [m, m])
  bad_message(@wire.copy_range(encoded, 0, 18))
}

///|
test "unknown attribute flags and nested attributes preserved" {
  let child : @wire.Attribute = { raw_kind: 123, payload: b"abc", }
  let outer : @wire.Attribute = {
    raw_kind: 0x8000 | 99,
    payload: @wire.encode_attributes([child]),
  }
  let attrs = @wire.decode_attributes(@wire.encode_attributes([outer]))
  assert_eq(attrs, [outer])
  assert_eq(attrs[0].kind(), 99)
  assert_true(attrs[0].nested())
  assert_eq(attrs[0].children(), [child])
  let net : @wire.Attribute = { raw_kind: 0x4001, payload: b"", }
  assert_true(net.network_order())
  assert_eq(net.kind(), 1)
}

///|
test "nested children require flag" {
  let a : @wire.Attribute = { raw_kind: 1, payload: b"", }
  try a.children() catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("missing nested flag")
  }
}

///|
test "attribute round trip and final unpadded TLV" {
  for order in [@wire.Little, @wire.Big] {
    for size in 0..<65 {
      let a : @wire.Attribute = {
        raw_kind: 65535,
        payload: Bytes::make(size, 255),
      }
      let encoded = @wire.encode_attributes([a], endian=order)
      assert_eq(@wire.decode_attributes(encoded, endian=order), [a])
      assert_eq(
        @wire.decode_attributes(
          @wire.copy_range(encoded, 0, 4 + size),
          endian=order,
        ),
        [a],
      )
    }
  }
}

///|
test "every attribute truncation rejected" {
  let a : @wire.Attribute = { raw_kind: 9, payload: b"abcdefghijkl", }
  let bytes = @wire.encode_attributes([a])
  for n in 1..<bytes.length() {
    bad_attribute(@wire.copy_range(bytes, 0, n))
  }
  for size in [0, 1, 2, 3, 65535] {
    let data : FixedArray[Byte] = FixedArray::make(4, 0)
    @wire.write_u16(data, 0, size)
    bad_attribute(Bytes::from_array(data))
  }
}

///|
test "attribute encoder rejects u16 overflow" {
  try
    @wire.encode_attributes([{ raw_kind: 1, payload: Bytes::make(65532, 0), }])
  catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("expected attribute length limit")
  }
}

///|
test "invalid kind cannot truncate to u16" {
  let m : @wire.Message = {
    header: { kind: -1, flags: 0, sequence: 0U, port: 0U, },
    payload: b"",
  }
  try @wire.encode(m) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("invalid kind")
  }
}

///|
test "checked integer offsets and write bounds" {
  for offset in [-1, 0, 1, 2147483647] {
    try @wire.u32(b"abc", offset) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("out of bounds")
    }
  }
  let data : FixedArray[Byte] = FixedArray::make(3, 0)
  try @wire.write_u32(data, 0, 1U) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("write out of bounds")
  }
  for n in [-1, 2147483645, 2147483647] {
    try @wire.align4(n) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("alignment overflow")
    }
  }
}

///|
test "signed errno and endian integer round trip" {
  for endian in [@wire.Little, @wire.Big] {
    for n in [0U, 1U, 0x7fffffffU, 0x80000000U, 0xffffffffU] {
      assert_eq(@wire.u32(@wire.uint_payload(n, endian~), 0, endian~), n)
    }
    assert_eq(
      @wire.i32(
        @wire.uint_payload((-22).reinterpret_as_uint(), endian~),
        0,
        endian~,
      ),
      -22,
    )
  }
}

///|
test "cstring strict UTF8 terminator and embedded NUL" {
  assert_eq(@wire.cstring(@wire.string_payload("网卡demo")), "网卡demo")
  assert_eq(@wire.cstring(b"\x00"), "")
  for data in [b"", b"no nul", b"a\x00b\x00", b"\xff\x00"] {
    try @wire.cstring(data) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("invalid cstring")
    }
  }
}

///|
test "mutation corpus terminates with data or typed error" {
  let golden = b"\x14\x00\x00\x00\x03\x00\x02\x00\x78\x56\x34\x12\x00\x00\x00\x00\x00\x00\x00\x00"
  for position in 0..<golden.length() {
    for value in 0..<256 {
      let data = golden.to_fixedarray()
      data[position] = value.to_byte()
      try @wire.decode(Bytes::from_array(data)) catch {
        @wire.ProtocolError(_) => ()
      } noraise {
        messages => assert_true(messages.length() <= 1)
      }
    }
  }
}
