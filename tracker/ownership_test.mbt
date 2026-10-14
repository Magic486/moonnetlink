///|
test "mutating original attribute arrays cannot change stored observations" {
  let state = @tracker.State::new()
  guard @route.decode(@scenarios.link()) is @route.LinkChanged(link, ..) else {
    fail("link")
  }
  state.apply(@route.LinkChanged(link, deleted=false))
  let expected = state.view()
  link.attributes.clear()
  assert_eq(state.view(), expected)
}

///|
test "view attribute mutation and array removal cannot change any cached object" {
  let state = @tracker.State::new()
  for
    message in [
      @scenarios.link(),
      @scenarios.address(),
      @scenarios.route(),
      @scenarios.neighbor(),
    ] {
    state.apply(@route.decode(message))
  }
  let before = state.view()
  let changed = state.view()
  changed.links[0].attributes.clear()
  changed.addresses[0].attributes.clear()
  changed.routes[0].attributes.clear()
  changed.neighbors[0].attributes.clear()
  changed.links.clear()
  changed.reasons.push("caller-only")
  assert_eq(state.view(), before)
}
