///|
test "Generic Netlink opens and closes independently from route sockets" {
  if !@native.is_linux() {
    return
  }
  let socket = @native.Socket::open(protocol=@native.Generic)
  assert_eq(socket.receive(timeout_ms=0), None)
  socket.close()
  socket.close()
  try socket.receive(timeout_ms=0) catch {
    @native.NativeError(_, errno) => assert_eq(errno, 9)
    error => raise error
  } noraise {
    _ => fail("closed generic socket received data")
  }
}

///|
test "Generic protocol refuses a route dump before sending a request" {
  if !@native.is_linux() {
    return
  }
  let socket = @native.Socket::open(protocol=@native.Generic)
  defer socket.close()
  try socket.dump(@route.Links) catch {
    @native.NativeError(_, errno) => assert_eq(errno, 22)
    error => raise error
  } noraise {
    _ => fail("route request sent on generic socket")
  }
}
