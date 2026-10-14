///|
pub(all) enum LookupStatus {
  Pending
  Complete
  Failed(String)
} derive(Debug, Eq, ToJson)

///|
/// A read-only controller query completes only after metadata AND successful ACK.
pub struct Lookup {
  sequence : UInt32
  name : String
  mut family : Family?
  mut acknowledged : Bool
  mut status : LookupStatus
}

///|
pub fn Lookup::new(
  sequence : UInt32,
  name : String,
) -> Lookup raise @wire.ProtocolError {
  ignore(family_request(name, sequence))
  { sequence, name, family: None, acknowledged: false, status: Pending, }
}

///|
pub fn Lookup::status(self : Lookup) -> LookupStatus {
  self.status
}

///|
fn[T] Lookup::reject(
  self : Lookup,
  reason : String,
) -> T raise @wire.ProtocolError {
  self.status = Failed(reason)
  raise @wire.ProtocolError(reason)
}

///|
pub fn Lookup::accept(
  self : Lookup,
  message : @wire.Message,
  endian~ : @wire.Endian = @wire.Little,
) -> Bool raise @wire.ProtocolError {
  if message.header.sequence != self.sequence {
    return false
  }
  guard self.status == Pending else {
    raise @wire.ProtocolError("family lookup already terminated")
  }
  if (message.header.flags & 0x10) != 0 {
    self.reject("interrupted family lookup")
  }
  match message.header.kind {
    2 => {
      let event = @route.decode(message, endian~) catch {
        @wire.ProtocolError(reason) => self.reject(reason)
      }
      guard event is @route.Acknowledged(ack) else {
        self.reject("expected ACK")
      }
      if ack.code != 0 {
        self.reject("kernel error \{ack.code}: \{ack.message.unwrap_or("")}")
      }
      self.acknowledged = true
    }
    16 => {
      let family = decode_family(message, endian~) catch {
        @wire.ProtocolError(reason) => self.reject(reason)
      }
      guard family.name == self.name else {
        self.reject("reply family does not match request")
      }
      guard self.family is None else { self.reject("duplicate family reply") }
      self.family = Some(family)
    }
    4 => self.reject("family lookup overrun")
    _ => self.reject("unexpected family lookup message")
  }
  if self.family is Some(_) && self.acknowledged {
    self.status = Complete
  }
  true
}

///|
pub fn Lookup::result(self : Lookup) -> Family raise @wire.ProtocolError {
  guard self.status == Complete && self.family is Some(family) else {
    raise @wire.ProtocolError("family lookup has no complete result")
  }
  family
}

///|
pub extend LookupStatus with Debug::{to_repr}

///|
pub extend LookupStatus with Eq::{equal, not_equal}

///|
pub extend LookupStatus with ToJson::{to_json}
