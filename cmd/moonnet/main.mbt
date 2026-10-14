///|
fn emit(json : Json) -> Unit {
  println(json.stringify())
  @native.flush_stdout()
}

///|
fn snapshot(record_path : String?) -> Unit raise {
  let socket = @native.Socket::open()
  defer socket.close()
  let state = @tracker.State::new()
  let lines : Array[String] = []
  for kind in [@route.Links, @route.Addresses, @route.Routes, @route.Neighbors] {
    let capture = socket.dump(kind)
    for event in capture.events {
      state.apply(event)
    }
    for data in capture.datagrams {
      lines.push(@journal.line(@journal.Datagram(data, capture.endian)))
    }
  }
  if record_path is Some(path) {
    @native.write_text(path, lines.join("\n") + "\n")
  }
  let view = state.view()
  emit({
    "kind": "snapshot",
    "complete_by_kind": true,
    "atomic_across_kinds": false,
    "links": Json(view.links),
    "addresses": Json(view.addresses),
    "routes": Json(view.routes),
    "neighbors": Json(view.neighbors),
  })
}

///|
fn replay(records : Array[@journal.Record], source : String) -> Unit raise {
  let state = @tracker.State::new()
  for record in records {
    match record {
      @journal.Datagram(data, endian) => state.ingest(data, endian~)
      @journal.Loss(reason) => state.mark_stale(reason)
    }
  }
  emit({ "kind": "replay", "source": source, "state": state.view().to_json() })
}

///|
fn seconds(value : String) -> Int32 raise @wire.ProtocolError {
  guard value.length() > 0 && value.length() <= 3 else {
    raise @wire.ProtocolError("seconds must be 1..60")
  }
  let mut n = 0
  for c in value {
    guard c >= '0' && c <= '9' else {
      raise @wire.ProtocolError("seconds must be 1..60")
    }
    n = n * 10 + c.to_int() - 48
  }
  guard n >= 1 && n <= 60 else {
    raise @wire.ProtocolError("seconds must be 1..60")
  }
  n
}

///|
fn watch(duration : Int32, path : String) -> Unit raise {
  let socket = @native.Socket::open(groups=0x555U)
  defer socket.close()
  @native.write_text(path, "")
  let state = @tracker.State::new()
  let deadline = @native.monotonic_ms() + (duration * 1000).to_int64()
  emit({
    "kind": "ready",
    "source": "live-kernel",
    "starts_partial": true,
    "seconds": duration,
  })
  let mut count = 0
  while @native.monotonic_ms() < deadline {
    let remaining = (deadline - @native.monotonic_ms()).to_int()
    if remaining <= 0 {
      break
    }
    let data = socket.receive(timeout_ms=remaining) catch {
      error => {
        let reason = Repr(error).to_string()
        state.mark_stale(reason)
        @native.write_text(
          path,
          @journal.line(@journal.Loss(reason)) + "\n",
          append=true,
        )
        emit({ "kind": "loss", "reason": reason })
        // ENOBUFS/EMSGSIZE are recoverable loss; closed sockets are not.
        match error {
          @native.NativeError(_, 105) | @native.NativeError(_, 90) => continue
          _ => raise error
        }
      }
    }
    if data is Some(bytes) {
      @native.write_text(
        path,
        @journal.line(@journal.Datagram(bytes, @native.host_endian())) + "\n",
        append=true,
      )
      let messages = @wire.decode(bytes, endian=@native.host_endian())
      let events = messages.map(m => {
        @route.decode(m, endian=@native.host_endian())
      })
      state.ingest(bytes, endian=@native.host_endian())
      for event in events {
        emit({ "kind": "event", "event": event.to_json() })
      }
      count += 1
      guard count <= 10000 else {
        raise @wire.ProtocolError("watch datagram budget exceeded")
      }
    }
  }
  emit({
    "kind": "watch-summary",
    "datagrams": count,
    "state": state.view().to_json(),
  })
}

///|
fn run(args : Array[String]) -> Unit raise {
  match args {
    [] | ["help"] | ["--help"] =>
      println(
        "MoonNetlink\n  snapshot [--record FILE]\n  watch SECONDS FILE (1..60 seconds, partial event cache)\n  replay FILE\n  demo (synthetic loss scenario)",
      )
    ["snapshot"] => snapshot(None)
    ["snapshot", "--record", path] => snapshot(Some(path))
    ["watch", duration, path] => watch(seconds(duration), path)
    ["replay", path] =>
      replay(@journal.parse(@native.read_text(path)), "recorded-datagrams")
    ["demo"] => replay(@scenarios.trace(), "synthetic-demo")
    _ => raise @wire.ProtocolError("invalid arguments; use --help")
  }
}

///|
fn main {
  let args = @env.args()
  run(args[1:].to_owned()) catch {
    error => {
      let json : Json = { "error": Repr(error).to_string() }
      @native.write_stderr(json.stringify() + "\n")
      @native.exit(1)
    }
  }
}
