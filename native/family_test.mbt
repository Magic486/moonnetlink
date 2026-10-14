///|
test "Linux resolves nlctrl metadata and ACK twice on the same socket" {
  if !@native.is_linux() {
    return
  }
  let socket = @native.Socket::open(protocol=@native.Generic)
  defer socket.close()
  for _ in 0..<2 {
    let capture = socket.family("nlctrl")
    assert_eq(capture.family.id, 16)
    assert_eq(capture.family.name, "nlctrl")
    assert_true(capture.datagrams.length() > 0)
  }
}

///|
test "Linux unknown family and wrong protocol fail without a successful result" {
  if !@native.is_linux() {
    return
  }
  let generic = @native.Socket::open(protocol=@native.Generic)
  defer generic.close()
  try generic.family("mn-no-such-fam") catch {
    @wire.ProtocolError(_) => ()
    error => raise error
  } noraise {
    _ => fail("unknown family found")
  }
  let route = @native.Socket::open()
  defer route.close()
  try route.family("nlctrl") catch {
    @native.NativeError(_, errno) => assert_eq(errno, 22)
    error => raise error
  } noraise {
    _ => fail("route protocol accepted family request")
  }
}
