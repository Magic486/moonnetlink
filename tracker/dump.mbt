///|
pub(all) enum DumpStatus {
  Pending
  Complete
  Failed(String)
} derive(Debug, Eq, ToJson)

///|
/// One request transaction. Unrelated messages cannot complete this dump.
pub struct Dump {
  sequence : UInt32
  kind : @route.ObjectKind
  mut status : DumpStatus
  events : Array[@route.Event]
} derive(Debug)

///|
pub fn Dump::new(sequence : UInt32, kind : @route.ObjectKind) -> Dump {
  { sequence, kind, status: Pending, events: [], }
}

///|
pub fn Dump::status(self : Dump) -> DumpStatus {
  self.status
}

///|
fn belongs(event : @route.Event, kind : @route.ObjectKind) -> Bool {
  match (event, kind) {
    (@route.LinkChanged(_, deleted=false), @route.Links)
    | (@route.AddressChanged(_, deleted=false), @route.Addresses)
    | (@route.RouteChanged(_, deleted=false), @route.Routes)
    | (@route.NeighborChanged(_, deleted=false), @route.Neighbors) => true
    _ => false
  }
}

///|
/// Returns false for a different request sequence. A zero ACK does not end a dump.
pub fn Dump::accept(
  self : Dump,
  message : @wire.Message,
  endian~ : @wire.Endian = @wire.Little,
) -> Bool raise @wire.ProtocolError {
  if message.header.sequence != self.sequence {
    return false
  }
  guard self.status == Pending else {
    raise @wire.ProtocolError("dump already terminal")
  }
  if (message.header.flags & 0x10) != 0 {
    self.status = Failed("kernel interrupted dump; discard and retry")
    return true
  }
  let event = @route.decode(message, endian~)
  match event {
    @route.Done(ack) =>
      self.status = if ack.code == 0 {
        Complete
      } else {
        Failed("DONE errno \{ack.code}")
      }
    @route.Acknowledged(ack) =>
      if ack.code != 0 {
        self.status = Failed(
          "kernel errno \{ack.code}: \{ack.message.unwrap_or("no extended ACK")}",
        )
      }
    @route.Overrun => self.status = Failed("Netlink overrun")
    _ =>
      if belongs(event, self.kind) {
        self.events.push(event)
      } else {
        self.status = Failed("unexpected object in dump")
      }
  }
  true
}

///|
/// Partial results are never returned as a successful snapshot.
pub fn Dump::result(
  self : Dump,
) -> Array[@route.Event] raise @wire.ProtocolError {
  match self.status {
    Complete => self.events.copy()
    Pending => raise @wire.ProtocolError("dump missing DONE")
    Failed(reason) => raise @wire.ProtocolError(reason)
  }
}

///|
pub extend DumpStatus with Debug::{to_repr}

///|
pub extend DumpStatus with Eq::{equal, not_equal}

///|
pub extend DumpStatus with ToJson::{to_json}

///|
pub extend Dump with Debug::{to_repr}
