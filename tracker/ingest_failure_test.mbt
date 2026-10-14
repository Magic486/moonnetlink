///|
test "unreadable datagram keeps objects and reports sticky loss" {
  let state = @tracker.State::new()
  state.apply(@route.decode(@scenarios.link()))
  try state.ingest(b"short") catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("malformed input accepted")
  }
  assert_eq(state.view().links.length(), 1)
  assert_true(state.view().stale)
  assert_eq(state.view().applied_events, 1)
  state.ingest(@wire.encode(@scenarios.link(index=8)))
  assert_true(state.view().stale)
  assert_eq(state.view().links.length(), 2)
}

///|
test "later invalid typed message prevents every event in the same datagram" {
  let state = @tracker.State::new()
  let valid = @scenarios.link()
  let invalid : @wire.Message = {
    header: { ..valid.header, kind: 20, },
    payload: b"",
  }
  try state.ingest(@wire.encode(valid) + @wire.encode(invalid)) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("invalid address accepted")
  }
  assert_eq(state.view().links.length(), 0)
  assert_eq(state.view().applied_events, 0)
  assert_true(state.view().stale)
  assert_eq(state.view().reasons, ["malformed route event"])
}
