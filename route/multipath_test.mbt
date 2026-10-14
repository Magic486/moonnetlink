///|
test "independent little endian multipath golden has weighted gateway and direct hop" {
  let hops = @route.decode_next_hops(
    b"\x10\x00\x03\x01\x07\x00\x00\x00\x08\x00\x05\x00\xc0\x00\x02\x01\x08\x00\x00\x00\x09\x00\x00\x00",
    2,
  )
  assert_eq(hops.length(), 2)
  assert_eq(hops[0].index, 7)
  assert_eq(hops[0].flags, 3)
  assert_eq(hops[0].weight, 2)
  assert_eq(hops[0].gateway, Some("192.0.2.1"))
  assert_eq(hops[1].index, 9)
  assert_eq(hops[1].weight, 1)
  assert_eq(hops[1].gateway, None)
}

///|
test "independent big endian multipath golden preserves IP byte order" {
  let hops = @route.decode_next_hops(
    b"\x00\x10\x03\x01\x00\x00\x00\x07\x00\x08\x00\x05\xc0\x00\x02\x01",
    2,
    endian=@wire.Big,
  )
  assert_eq(hops[0].index, 7)
  assert_eq(hops[0].gateway, Some("192.0.2.1"))
}

///|
test "every incomplete next hop fails and a complete boundary succeeds" {
  let bytes = b"\x10\x00\x00\x00\x07\x00\x00\x00\x08\x00\x05\x00\xc0\x00\x02\x01\x08\x00\x00\x00\x09\x00\x00\x00"
  for size in 1..<bytes.length() {
    if size == 16 {
      continue
    }
    try @route.decode_next_hops(@wire.copy_range(bytes, 0, size), 2) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("partial hop accepted at \{size}")
    }
  }
  assert_eq(
    @route.decode_next_hops(@wire.copy_range(bytes, 0, 16), 2).length(),
    1,
  )
}

///|
test "zero undersized and overlong rtnexthop lengths are rejected" {
  for
    bytes in [
      b"\x00\x00\x00\x00\x00\x00\x00\x00", b"\x07\x00\x00\x00\x00\x00\x00\x00", b"\xff\xff\x00\x00\x00\x00\x00\x00",
    ] {
    try @route.decode_next_hops(bytes, 2) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("invalid length accepted")
    }
  }
}

///|
test "unknown hop attributes and maximum kernel weight survive" {
  let hops = @route.decode_next_hops(
    b"\x0c\x00\x80\xff\x07\x00\x00\x00\x04\x00\x2a\x80", 2,
  )
  assert_eq(hops[0].weight, 256)
  assert_eq(hops[0].attributes[0].raw_kind, 0x802a)
}

///|
test "Route convenience API retains existing single path behavior" {
  guard @route.decode(@scenarios.route()) is @route.RouteChanged(route, ..) else {
    fail("route")
  }
  assert_eq(route.next_hops().length(), 0)
  let multi = {
    ..route,
    attributes: [{ raw_kind: 9, payload: b"\x08\x00\x00\x00\x07\x00\x00\x00", }],
  }
  assert_eq(multi.next_hops()[0].index, 7)
}
