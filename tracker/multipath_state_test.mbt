///|
fn multipath_message(endian : @wire.Endian) -> @wire.Message raise {
  let base = @scenarios.route()
  let data : FixedArray[Byte] = FixedArray::make(8, 0)
  @wire.write_u16(data, 0, 8, endian~)
  @wire.write_u32(data, 4, 7U, endian~)
  let attrs : Array[@wire.Attribute] = [
    { raw_kind: 9, payload: Bytes::from_array(data), },
  ]
  {
    ..base,
    payload: @wire.copy_range(base.payload, 0, 12) +
    @wire.encode_attributes(attrs, endian~),
  }
}

///|
test "deleted interface clears multipath routes in either original byte order" {
  for endian in [@wire.Little, @wire.Big] {
    let state = @tracker.State::new()
    state.ingest(@wire.encode(multipath_message(endian), endian~), endian~)
    assert_eq(state.view().routes.length(), 1)
    state.apply(@route.decode(@scenarios.link(index=9, deleted=true)))
    assert_eq(state.view().routes.length(), 1)
    state.apply(@route.decode(@scenarios.link(index=7, deleted=true)))
    assert_eq(state.view().routes.length(), 0)
  }
}

///|
test "route decoder rejects invalid multipath before earlier datagram events apply" {
  let base = @scenarios.route()
  let payload = @wire.copy_range(base.payload, 0, 12) +
    @wire.encode_attributes([{ raw_kind: 9, payload: b"bad", }])
  let state = @tracker.State::new()
  try
    state.ingest(
      @wire.encode(@scenarios.link()) + @wire.encode({ ..base, payload, }),
    )
  catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("invalid multipath accepted")
  }
  assert_eq(state.view().applied_events, 0)
  assert_eq(state.view().links.length(), 0)
  assert_true(state.view().stale)
}

///|
test "direct typed invalid route invalidates state without inserting it" {
  guard @route.decode(@scenarios.route()) is @route.RouteChanged(route, ..) else {
    fail("route")
  }
  let invalid = { ..route, attributes: [{ raw_kind: 9, payload: b"bad", }], }
  let state = @tracker.State::new()
  state.apply(@route.RouteChanged(invalid, deleted=false))
  assert_eq(state.view().routes.length(), 0)
  assert_eq(state.view().applied_events, 0)
  assert_true(state.view().stale)
}
