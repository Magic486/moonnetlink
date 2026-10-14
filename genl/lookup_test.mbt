///|
fn reply(name~ : String = "nlctrl") -> @wire.Message raise @wire.ProtocolError {
  let request = @genl.family_request(name, 42U)
  let envelope = @genl.decode(request.payload)
  envelope.attributes.push({ raw_kind: 1, payload: b"\x10\x00", })
  {
    header: { ..request.header, flags: 0, },
    payload: @genl.encode({ ..envelope, command: 1, }),
  }
}

///|
test "metadata and ACK may arrive in either order but neither alone completes" {
  for first_ack in [false, true] {
    let lookup = @genl.Lookup::new(42U, "nlctrl")
    let ack = @scenarios.control(2, sequence=42U)
    ignore(lookup.accept(if first_ack { ack } else { reply() }))
    assert_eq(lookup.status(), @genl.Pending)
    try lookup.result() catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("partial result exposed")
    }
    ignore(lookup.accept(if first_ack { reply() } else { ack }))
    assert_eq(lookup.status(), @genl.Complete)
    assert_eq(lookup.result().name, "nlctrl")
  }
}

///|
test "unrelated malformed payload is ignored before decoding" {
  let lookup = @genl.Lookup::new(42U, "nlctrl")
  let unrelated : @wire.Message = {
    header: { kind: 16, flags: 0, sequence: 99U, port: 0U, },
    payload: b"bad",
  }
  assert_false(lookup.accept(unrelated))
  assert_eq(lookup.status(), @genl.Pending)
}

///|
test "negative error interruption overrun and wrong family cause sticky failure" {
  let interrupted = { ..reply(), header: { ..reply().header, flags: 0x10, }, }
  for
    event in [
      @scenarios.control(2, sequence=42U, code=-2),
      @scenarios.control(4, sequence=42U),
      interrupted,
      reply(name="other"),
    ] {
    let lookup = @genl.Lookup::new(42U, "nlctrl")
    try lookup.accept(event) catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("bad reply accepted")
    }
    assert_true(lookup.status() is @genl.Failed(_))
    try lookup.result() catch {
      @wire.ProtocolError(_) => ()
    } noraise {
      _ => fail("failed result exposed")
    }
  }
}

///|
test "duplicate metadata and malformed control data fail permanently" {
  let lookup = @genl.Lookup::new(42U, "nlctrl")
  ignore(lookup.accept(reply()))
  try lookup.accept(reply()) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("duplicate accepted")
  }
  assert_true(lookup.status() is @genl.Failed(_))
  let malformed = @genl.Lookup::new(42U, "nlctrl")
  try malformed.accept({ ..reply(), payload: b"bad", }) catch {
    @wire.ProtocolError(_) => ()
  } noraise {
    _ => fail("malformed accepted")
  }
  assert_true(malformed.status() is @genl.Failed(_))
}
