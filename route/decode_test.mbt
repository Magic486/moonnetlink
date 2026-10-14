///|
test "typed link golden values and preserved attributes" {
  guard @route.decode(@scenarios.link())
    is @route.LinkChanged(link, deleted=false) else {
    fail("link event")
  }
  assert_eq(link.index, 7)
  assert_eq(link.name, Some("demo0"))
  assert_eq(link.mtu, Some(1500U))
  assert_eq(link.operstate, Some(6))
  assert_eq(link.address, Some("02:00:00:00:00:07"))
  assert_eq(link.attributes.length(), 4)
}

///|
test "big endian link does not change address bytes" {
  guard @route.decode(@scenarios.link(endian=@wire.Big), endian=@wire.Big)
    is @route.LinkChanged(link, ..) else {
    fail("link")
  }
  assert_eq(link.index, 7)
  assert_eq(link.mtu, Some(1500U))
  assert_eq(link.address, Some("02:00:00:00:00:07"))
}

///|
test "IPv4 address local vs peer fields" {
  guard @route.decode(@scenarios.address())
    is @route.AddressChanged(a, deleted=false) else {
    fail("address")
  }
  assert_eq(a.index, 7U)
  assert_eq(a.prefix_length, 24)
  assert_eq(a.local_address, Some("192.0.2.7"))
  assert_eq(a.address, Some("192.0.2.7"))
  assert_eq(a.label, Some("demo0"))
}

///|
test "route table metric interface and destination" {
  guard @route.decode(@scenarios.route())
    is @route.RouteChanged(r, deleted=false) else {
    fail("route")
  }
  assert_eq(r.destination, Some("192.0.2.0"))
  assert_eq(r.table, 254U)
  assert_eq(r.output_interface, Some(7U))
  assert_eq(r.priority, Some(100U))
  assert_eq(r.destination_prefix, 24)
}

///|
test "neighbor state and hardware address" {
  guard @route.decode(@scenarios.neighbor())
    is @route.NeighborChanged(n, deleted=false) else {
    fail("neighbor")
  }
  assert_eq(n.index, 7)
  assert_eq(n.state, 2)
  assert_eq(n.destination, Some("192.0.2.8"))
  assert_eq(n.lladdr, Some("02:00:00:00:00:08"))
}

///|
test "delete event kinds" {
  guard @route.decode(@scenarios.link(deleted=true))
    is @route.LinkChanged(_, deleted=true) else {
    fail("delete link")
  }
  guard @route.decode(@scenarios.address(deleted=true))
    is @route.AddressChanged(_, deleted=true) else {
    fail("delete address")
  }
  guard @route.decode(@scenarios.route(deleted=true))
    is @route.RouteChanged(_, deleted=true) else {
    fail("delete route")
  }
  guard @route.decode(@scenarios.neighbor(deleted=true))
    is @route.NeighborChanged(_, deleted=true) else {
    fail("delete neighbor")
  }
}

///|
test "fixed header truncations never panic" {
  for
    m in [
      @scenarios.link(),
      @scenarios.address(),
      @scenarios.route(),
      @scenarios.neighbor(),
    ] {
    let minimum = match m.header.kind {
      16 => 16
      20 => 8
      _ => 12
    }
    for n in 0..<minimum {
      let truncated : @wire.Message = {
        ..m,
        payload: @wire.copy_range(m.payload, 0, n),
      }
      try @route.decode(truncated) catch {
        @wire.ProtocolError(_) => ()
      } noraise {
        _ => fail("truncated fixed header")
      }
    }
  }
}

///|
test "unknown message remains round trippable" {
  let m : @wire.Message = {
    header: { kind: 65535, flags: 0, sequence: 0U, port: 0U, },
    payload: b"opaque",
  }
  assert_eq(@route.decode(m), @route.Unknown(m))
}

///|
test "unknown attribute is retained" {
  let m = @scenarios.link()
  let unknown : @wire.Attribute = { raw_kind: 4095, payload: b"opaque", }
  let extended : @wire.Message = {
    ..m,
    payload: m.payload + @wire.encode_attributes([unknown]),
  }
  guard @route.decode(extended) is @route.LinkChanged(link, ..) else {
    fail("link")
  }
  assert_eq(link.attributes[4], unknown)
}

///|
test "ACK errno and successful acknowledgement" {
  guard @route.decode(@scenarios.control(2, code=-22)) is @route.Acknowledged(a) else {
    fail("ack")
  }
  assert_eq(a.code, -22)
  guard @route.decode(@scenarios.control(2)) is @route.Acknowledged(a) else {
    fail("ack")
  }
  assert_eq(a.code, 0)
}

///|
test "capped extended ACK text and error offset" {
  let m = @scenarios.control(2, flags=0x300, code=-22)
  let ext = @wire.encode_attributes([
    { raw_kind: 1, payload: b"bad mtu\x00", },
    { raw_kind: 2, payload: @wire.uint_payload(24U), },
  ])
  guard @route.decode({ ..m, payload: m.payload + ext, })
    is @route.Acknowledged(a) else {
    fail("ack")
  }
  assert_eq(a.message, Some("bad mtu"))
  assert_eq(a.bad_offset, Some(24U))
}

///|
test "uncapped extended ACK skips echoed request body" {
  let m = @scenarios.control(2, flags=0x200, code=-22)
  let payload = @wire.uint_payload((-22).reinterpret_as_uint()) +
    @wire.uint_payload(20U) +
    Bytes::make(16, 0) +
    @wire.encode_attributes([{ raw_kind: 1, payload: b"bad input\x00", }])
  guard @route.decode({ ..m, payload, }) is @route.Acknowledged(a) else {
    fail("ack")
  }
  assert_eq(a.message, Some("bad input"))
}

///|
test "ACK and DONE malformed control payload rejected" {
  for n in 0..<20 {
    let m = @scenarios.control(2)
    try @route.decode({ ..m, payload: Bytes::make(n, 0), }) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("short ACK")
    }
  }
  for n in 1..<4 {
    let m = @scenarios.control(3)
    try @route.decode({ ..m, payload: Bytes::make(n, 0), }) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("short DONE")
    }
  }
}

///|
test "DONE empty old kernel or negative errno" {
  let m = @scenarios.control(3)
  guard @route.decode({ ..m, payload: b"", }) is @route.Done(a) else {
    fail("done")
  }
  assert_eq(a.code, 0)
  guard @route.decode(@scenarios.control(3, code=-4)) is @route.Done(a) else {
    fail("done")
  }
  assert_eq(a.code, -4)
}

///|
test "IPv6 address format and invalid IP lengths" {
  assert_eq(
    @route.ip_address(
      b"\x20\x01\x0d\xb8\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01", 10,
    ),
    "2001:0db8:0000:0000:0000:0000:0000:0001",
  )
  for family in [2, 10] {
    try @route.ip_address(b"bad", family) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("IP length")
    }
  }
}

///|
test "dump builders are read-only with exact fixed sizes" {
  for
    (kind, number, size) in [
      (@route.Links, 18, 16),
      (@route.Addresses, 22, 8),
      (@route.Routes, 26, 12),
      (@route.Neighbors, 30, 12),
    ] {
    let m = @route.request(kind, 123U)
    assert_eq(m.header.kind, number)
    assert_eq(m.header.sequence, 123U)
    assert_eq(m.header.flags, 0x301)
    assert_eq(m.payload.length(), size)
  }
}
