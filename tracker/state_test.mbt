///|
test "link replacement is keyed by index and delete is idempotent" {
  let state = @tracker.State::new()
  state.apply(@route.decode(@scenarios.link()))
  state.apply(@route.decode(@scenarios.link(mtu=9000U)))
  assert_eq(state.view().links.length(), 1)
  assert_eq(state.view().links[0].mtu, Some(9000U))
  state.apply(@route.decode(@scenarios.link(deleted=true)))
  state.apply(@route.decode(@scenarios.link(deleted=true)))
  assert_eq(state.view().links.length(), 0)
}

///|
test "link deletion cascades owned objects" {
  let state = @tracker.State::new()
  for
    m in [
      @scenarios.link(),
      @scenarios.address(),
      @scenarios.route(),
      @scenarios.neighbor(),
    ] {
    state.apply(@route.decode(m))
  }
  state.apply(@route.decode(@scenarios.link(index=8, name="other0")))
  state.apply(@route.decode(@scenarios.link(deleted=true)))
  assert_eq(state.view().links.length(), 1)
  assert_eq(state.view().links[0].index, 8)
  assert_eq(state.view().addresses.length(), 0)
  assert_eq(state.view().routes.length(), 0)
  assert_eq(state.view().neighbors.length(), 0)
}

///|
test "address route and neighbor upsert and explicit delete" {
  let state = @tracker.State::new()
  for m in [@scenarios.address(), @scenarios.route(), @scenarios.neighbor()] {
    state.apply(@route.decode(m))
    state.apply(@route.decode(m))
  }
  assert_eq(state.view().addresses.length(), 1)
  assert_eq(state.view().routes.length(), 1)
  assert_eq(state.view().neighbors.length(), 1)
  for
    m in [
      @scenarios.address(deleted=true),
      @scenarios.route(deleted=true),
      @scenarios.neighbor(deleted=true),
    ] {
    state.apply(@route.decode(m))
  }
  assert_eq(
    state.view().addresses.length() +
    state.view().routes.length() +
    state.view().neighbors.length(),
    0,
  )
}

///|
test "neighbor MAC change replaces same IP object" {
  let state = @tracker.State::new()
  state.apply(@route.decode(@scenarios.neighbor()))
  state.apply(
    @route.decode(@scenarios.neighbor(state=4, mac=b"\x02\x00\x00\x00\x00\xff")),
  )
  assert_eq(state.view().neighbors.length(), 1)
  assert_eq(state.view().neighbors[0].lladdr, Some("02:00:00:00:00:ff"))
  assert_eq(state.view().neighbors[0].state, 4)
}

///|
test "loss stays stale after later apparently valid data" {
  let state = @tracker.State::new()
  state.mark_stale("ENOBUFS")
  state.mark_stale("ENOBUFS")
  state.apply(@route.decode(@scenarios.link()))
  assert_true(state.view().stale)
  assert_true(state.view().starts_partial)
  assert_eq(state.view().reasons, ["ENOBUFS"])
}

///|
test "overrun and kernel failure mark state stale" {
  for m in [@scenarios.control(4), @scenarios.control(2, code=-22)] {
    let state = @tracker.State::new()
    state.apply(@route.decode(m))
    assert_true(state.view().stale)
  }
}

///|
test "bad later message leaves whole datagram unapplied" {
  let state = @tracker.State::new()
  let good = @wire.encode(@scenarios.link())
  let bad = @wire.encode({
    header: { kind: 20, flags: 0, sequence: 0U, port: 0U, },
    payload: b"",
  })
  try state.ingest(good + bad) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("bad payload")
  }
  assert_eq(state.view().links.length(), 0)
  assert_eq(state.view().applied_events, 0)
}

///|
test "interrupted datagram marks stale and successful ACK does not" {
  let state = @tracker.State::new()
  state.ingest(@wire.encode(@scenarios.control(2)))
  assert_false(state.view().stale)
  state.ingest(@wire.encode(@scenarios.control(3, flags=0x10)))
  assert_true(state.view().stale)
}

///|
test "view array mutation cannot remove cached objects" {
  let state = @tracker.State::new()
  state.apply(@route.decode(@scenarios.link()))
  let view = state.view()
  view.links.clear()
  assert_eq(state.view().links.length(), 1)
}
