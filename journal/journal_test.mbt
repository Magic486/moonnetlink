///|
test "hex independent golden and all byte values" {
  assert_eq(@journal.hex(b"\x00\x01\x10\xab\xff"), "000110abff")
  assert_eq(@journal.unhex("AbFF00"), b"\xab\xff\x00")
  let bytes = Bytes::makei(256, i => i.to_byte())
  assert_eq(@journal.unhex(@journal.hex(bytes)), bytes)
}

///|
test "odd or invalid hex is rejected" {
  for value in ["0", "001", "zz", "-1", "0 ", "🎉"] {
    try @journal.unhex(value) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("invalid hex")
    }
  }
}

///|
test "journal endian and loss round trip" {
  for
    r in [
      @journal.Datagram(b"\xff\x01", @wire.Little),
      @journal.Datagram(b"\xff\x01", @wire.Big),
      @journal.Loss("丢失\nnext"),
    ] {
    assert_eq(@journal.parse_line(@journal.line(r)), r)
  }
}

///|
test "JSONL CRLF blank lines and loss ordering" {
  let a = @journal.Datagram(b"\x00", @wire.Big)
  let b = @journal.Loss("ENOBUFS")
  assert_eq(
    @journal.parse(
      "\r\n" + @journal.line(a) + "\r\n\n" + @journal.line(b) + "\n",
    ),
    [a, b],
  )
}

///|
test "journal version and schema errors" {
  for
    line in [
      "{}", "not json", "{\"version\":2,\"kind\":\"loss\",\"reason\":\"x\"}", "{\"version\":1,\"kind\":\"datagram\",\"endian\":\"guess\",\"hex\":\"00\"}",
      "{\"version\":1,\"kind\":\"datagram\",\"endian\":\"big\",\"hex\":\"z0\"}",
    ] {
    try @journal.parse_line(line) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("invalid schema")
    }
  }
}
