///|
test "record replay and line streaming have identical states and metrics" {
  let records = @scenarios.trace()
  let direct = @replay.Session::new()
  let streamed = @replay.Session::new()
  for record in records {
    direct.apply(record)
    streamed.apply_line(@journal.line(record))
  }
  assert_eq(direct.summary(), streamed.summary())
  assert_eq(direct.summary().records, 7)
  assert_eq(direct.summary().datagrams, 6)
  assert_eq(direct.summary().losses, 1)
  assert_eq(direct.summary().rejected, 0)
  assert_true(direct.summary().state.stale)
}

///|
test "invalid JSON record preserves completed observations and adds rejection" {
  let session = @replay.Session::new()
  session.apply(
    @journal.Datagram(@wire.encode(@scenarios.link()), @wire.Little),
  )
  try session.apply_line("not json") catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("invalid journal accepted")
  }
  assert_eq(session.summary().state.links.length(), 1)
  assert_eq(session.summary().records, 2)
  assert_eq(session.summary().rejected, 1)
  assert_true(session.summary().state.stale)
}

///|
test "malformed datagram records loss without partial application and can be followed by valid records" {
  let session = @replay.Session::new()
  try session.apply(@journal.Datagram(b"broken", @wire.Little)) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("bad data accepted")
  }
  session.apply(
    @journal.Datagram(@wire.encode(@scenarios.link()), @wire.Little),
  )
  assert_eq(session.summary().datagrams, 2)
  assert_eq(session.summary().rejected, 1)
  assert_eq(session.summary().state.applied_events, 1)
  assert_true(session.summary().state.stale)
}

///|
test "CRLF blank lines and big endian records are handled without changing snapshots" {
  let session = @replay.Session::new()
  let record = @journal.Datagram(
    @wire.encode(@scenarios.link(endian=@wire.Big), endian=@wire.Big),
    @wire.Big,
  )
  session.feed("\r\n  \n" + @journal.line(record) + "\r\n")
  assert_eq(session.summary().records, 1)
  let view = session.summary().state
  view.links[0].attributes.clear()
  assert_true(session.summary().state.links[0].attributes.length() > 0)
}
