///|
#external
type Handle

///|
extern "C" fn open_raw(groups : UInt32) -> Handle = "mn_open"

///|
#borrow(handle)
extern "C" fn status_raw(handle : Handle) -> Int32 = "mn_status"

///|
#borrow(handle)
extern "C" fn close_raw(handle : Handle) -> Unit = "mn_close"

///|
#borrow(handle, data)
extern "C" fn send_raw(handle : Handle, data : Bytes) -> Int32 = "mn_send"

///|
#borrow(handle)
extern "C" fn receive_raw(handle : Handle, timeout_ms : Int32) -> Bytes = "mn_receive"

///|
extern "C" fn little_raw() -> Bool = "mn_little"

///|
pub extern "C" fn monotonic_ms() -> Int64 = "mn_monotonic"

///|
/// Build-host feature probe, not a guarantee of socket permission in a sandbox.
pub extern "C" fn is_linux() -> Bool = "mn_is_linux"

///|
pub(all) suberror NativeError {
  NativeError(String, Int32)
} derive(Debug)

///|
pub struct Socket {
  handle : Handle
  mut sequence : UInt32
  endian : @wire.Endian
}

///|
pub fn host_endian() -> @wire.Endian {
  if little_raw() {
    @wire.Little
  } else {
    @wire.Big
  }
}

///|
/// NETLINK_ROUTE socket, kernel-assigned port, automatic finalizer plus explicit close.
/// groups=0 for dumps; groups=0x555 for link, address, route and neighbor notifications.
pub fn Socket::open(groups~ : UInt32 = 0U) -> Socket raise NativeError {
  let handle = open_raw(groups)
  let status = status_raw(handle)
  guard status >= 0 else { raise NativeError("open NETLINK_ROUTE", -status) }
  { handle, sequence: 0U, endian: host_endian(), }
}

///|
pub fn Socket::close(self : Socket) -> Unit {
  close_raw(self.handle)
}

///|
pub fn Socket::send(self : Socket, message : @wire.Message) -> Unit raise {
  let bytes = @wire.encode(message, endian=self.endian)
  let n = send_raw(self.handle, bytes)
  guard n == bytes.length() else {
    raise NativeError("send NETLINK_ROUTE", if n < 0 { -n } else { 5 })
  }
}

///|
fn unwrap_frame(frame : Bytes) -> Bytes raise {
  let status = @wire.i32(frame, 0)
  guard status >= 0 else { raise NativeError("native I/O", -status) }
  guard frame.length() - 4 == status else {
    raise NativeError("invalid native I/O frame", 71)
  }
  @wire.copy_range(frame, 4, status)
}

///|
/// None is a bounded poll timeout; transport loss is an error, never an empty snapshot.
pub fn Socket::receive(
  self : Socket,
  timeout_ms~ : Int32 = 2000,
) -> Bytes? raise {
  guard timeout_ms >= 0 && timeout_ms <= 60000 else {
    raise NativeError("timeout out of range", 22)
  }
  let bytes = unwrap_frame(receive_raw(self.handle, timeout_ms))
  if bytes.length() == 0 {
    None
  } else {
    Some(bytes)
  }
}

///|
/// Captured raw datagrams permit exact offline reproduction; complete means DONE checked.
pub(all) struct Capture {
  events : Array[@route.Event]
  datagrams : Array[Bytes]
  endian : @wire.Endian
} derive(Debug, ToJson)

///|
pub fn Socket::dump(
  self : Socket,
  kind : @route.ObjectKind,
  timeout_ms~ : Int32 = 5000,
) -> Capture raise {
  guard timeout_ms > 0 && timeout_ms <= 60000 else {
    raise NativeError("dump timeout out of range", 22)
  }
  self.sequence += 1U
  if self.sequence == 0U {
    self.sequence = 1U
  }
  let transaction = @tracker.Dump::new(self.sequence, kind)
  let datagrams : Array[Bytes] = []
  self.send(@route.request(kind, self.sequence))
  let deadline = monotonic_ms() + timeout_ms.to_int64()
  while transaction.status() == @tracker.Pending {
    let remaining = deadline - monotonic_ms()
    guard remaining > 0 else {
      raise NativeError("dump timed out before DONE", 110)
    }
    let bytes = match self.receive(timeout_ms=remaining.to_int()) {
      None => raise NativeError("dump timed out before DONE", 110)
      Some(bytes) => bytes
    }
    datagrams.push(bytes)
    guard datagrams.length() <= 4096 else {
      raise NativeError("dump datagram budget exceeded", 7)
    }
    for message in @wire.decode(bytes, endian=self.endian) {
      // Later unrelated frames (e.g. ACK) cannot modify the completed transaction.
      if transaction.status() == @tracker.Pending {
        ignore(transaction.accept(message, endian=self.endian))
      }
    }
  }
  { events: transaction.result(), datagrams, endian: self.endian, }
}

///|
pub extend NativeError with Debug::{to_repr}

///|
pub extend Capture with Debug::{to_repr}

///|
pub extend Capture with ToJson::{to_json}
