///|
pub(all) struct FamilyCapture {
  family : @genl.Family
  datagrams : Array[Bytes]
  endian : @wire.Endian
} derive(Debug, ToJson)

///|
/// Read-only Generic Netlink controller lookup with seq, ACK, timeout and input budget.
pub fn Socket::family(
  self : Socket,
  name : String,
  timeout_ms~ : Int32 = 5000,
) -> FamilyCapture raise {
  guard self.protocol == Generic else {
    raise NativeError("family lookup requires Generic protocol", 22)
  }
  guard timeout_ms > 0 && timeout_ms <= 60000 else {
    raise NativeError("family lookup timeout out of range", 22)
  }
  self.sequence += 1U
  if self.sequence == 0U {
    self.sequence = 1U
  }
  let lookup = @genl.Lookup::new(self.sequence, name)
  self.send(@genl.family_request(name, self.sequence, endian=self.endian))
  let deadline = monotonic_ms() + timeout_ms.to_int64()
  let datagrams : Array[Bytes] = []
  while lookup.status() == @genl.Pending {
    let remaining = deadline - monotonic_ms()
    guard remaining > 0 else {
      raise NativeError("family lookup timed out", 110)
    }
    let data = match self.receive(timeout_ms=remaining.to_int()) {
      Some(data) => data
      None => raise NativeError("family lookup timed out", 110)
    }
    datagrams.push(data)
    guard datagrams.length() <= 4096 else {
      raise NativeError("family lookup datagram budget exceeded", 7)
    }
    for message in @wire.decode(data, endian=self.endian) {
      if lookup.status() == @genl.Pending {
        ignore(lookup.accept(message, endian=self.endian))
      }
    }
  }
  { family: lookup.result(), datagrams, endian: self.endian, }
}

///|
pub extend FamilyCapture with Debug::{to_repr}

///|
pub extend FamilyCapture with ToJson::{to_json}
