///|
test "dump requires matching DONE and zero ACK is not DONE" {
  let dump = @tracker.Dump::new(42U, @route.Links)
  assert_false(dump.accept(@scenarios.control(3, sequence=99U)))
  assert_true(dump.accept(@scenarios.control(2, sequence=42U)))
  assert_eq(dump.status(), @tracker.Pending)
  let m = @scenarios.link()
  assert_true(dump.accept({ ..m, header: { ..m.header, sequence: 42U, }, }))
  assert_true(dump.accept(@scenarios.control(3, sequence=42U)))
  assert_eq(dump.status(), @tracker.Complete)
  assert_eq(dump.result().length(), 1)
}

///|
test "pending partial data is never successful result" {
  let dump = @tracker.Dump::new(0U, @route.Links)
  ignore(dump.accept(@scenarios.link()))
  try dump.result() catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("pending data escaped")
  }
}

///|
test "dump interruption on data or DONE invalidates all partial data" {
  for kind in [16, 3] {
    let dump = @tracker.Dump::new(0U, @route.Links)
    ignore(dump.accept(@scenarios.link()))
    let m = if kind == 3 {
      @scenarios.control(3, flags=0x10)
    } else {
      @scenarios.link()
    }
    ignore(dump.accept({ ..m, header: { ..m.header, flags: 0x10, }, }))
    guard dump.status() is @tracker.Failed(_) else { fail("interruption") }
    try dump.result() catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("partial dump escaped")
    }
  }
}

///|
test "negative ACK and negative DONE fail dump" {
  for kind in [2, 3] {
    let dump = @tracker.Dump::new(0U, @route.Links)
    ignore(dump.accept(@scenarios.control(kind, code=-22)))
    guard dump.status() is @tracker.Failed(_) else { fail("kernel failure") }
  }
}

///|
test "overrun and wrong object fail dump" {
  for
    m in [
      @scenarios.control(4),
      @scenarios.address(),
      @scenarios.link(deleted=true),
    ] {
    let dump = @tracker.Dump::new(0U, @route.Links)
    ignore(dump.accept(m))
    guard dump.status() is @tracker.Failed(_) else { fail("invalid dump") }
  }
}

///|
test "terminal transaction cannot be accepted again" {
  let dump = @tracker.Dump::new(0U, @route.Links)
  ignore(dump.accept(@scenarios.control(3)))
  try dump.accept(@scenarios.control(3)) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("double done")
  }
}

///|
test "unrelated sequence does not decode malformed payload" {
  let dump = @tracker.Dump::new(1U, @route.Links)
  let m : @wire.Message = {
    header: { kind: 16, flags: 0, sequence: 2U, port: 0U, },
    payload: b"",
  }
  assert_false(dump.accept(m))
  assert_eq(dump.status(), @tracker.Pending)
}
