///|
test "self-recorded Linux events replay all four object types plus IPv6" {
  let state = @tracker.State::new()
  let records = @journal.parse(@fixtures.journal_text())
  let kinds : Map[String, Bool] = Map([])
  let mut ipv6 = false
  for record in records {
    guard record is @journal.Datagram(data, endian) else {
      fail("expected real datagram")
    }
    for m in @wire.decode(data, endian~) {
      match @route.decode(m, endian~) {
        @route.LinkChanged(_, ..) => kinds["link"] = true
        @route.AddressChanged(a, ..) => {
          kinds["address"] = true
          if a.family == 10 {
            ipv6 = true
          }
        }
        @route.RouteChanged(_, ..) => kinds["route"] = true
        @route.NeighborChanged(_, ..) => kinds["neighbor"] = true
        _ => ()
      }
    }
    state.ingest(data, endian~)
  }
  assert_eq(kinds.length(), 4)
  assert_true(ipv6)
  assert_eq(state.view().applied_events, 32)
  assert_false(state.view().stale)
  assert_eq(
    state.view().links.length() +
    state.view().addresses.length() +
    state.view().routes.length() +
    state.view().neighbors.length(),
    0,
  )
}
