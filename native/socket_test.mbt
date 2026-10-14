///|
test "Linux native dump all object kinds returns checked complete transactions" {
  if @native.is_linux() {
    let socket = @native.Socket::open()
    defer socket.close()
    for
      kind in [@route.Links, @route.Addresses, @route.Routes, @route.Neighbors] {
      let capture = socket.dump(kind)
      assert_true(capture.datagrams.length() > 0)
      if kind == @route.Links {
        assert_true(capture.events.length() > 0)
      }
    }
  } else {
    try @native.Socket::open() catch {
      @native.NativeError(_, 95) => ()
      error => raise error
    } noraise {
      _ => fail("Linux socket on unsupported host")
    }
  }
}

///|
test "close is idempotent and use after close is typed EBADF" {
  if @native.is_linux() {
    let socket = @native.Socket::open()
    socket.close()
    socket.close()
    try socket.receive(timeout_ms=0) catch {
      @native.NativeError(_, 9) => ()
      error => raise error
    } noraise {
      _ => fail("read after close")
    }
  }
}

///|
test "idle receive times out without fake packet" {
  if @native.is_linux() {
    let socket = @native.Socket::open()
    defer socket.close()
    let start = @native.monotonic_ms()
    assert_eq(socket.receive(timeout_ms=15), None)
    assert_true(@native.monotonic_ms() - start < 1000L)
  }
}

///|
test "dump timeouts outside supported range are rejected before send" {
  if @native.is_linux() {
    let socket = @native.Socket::open()
    defer socket.close()
    for timeout in [0, -1, 60001] {
      try socket.dump(@route.Links, timeout_ms=timeout) catch {
        @native.NativeError(_, 22) => ()
        error => raise error
      } noraise {
        _ => fail("invalid timeout")
      }
    }
  }
}

///|
test "file path rejects embedded NUL" {
  try @native.read_text("x\u0000y") catch {
    @native.NativeError(_, 22) => ()
    error => raise error
  } noraise {
    _ => fail("NUL path")
  }
}
