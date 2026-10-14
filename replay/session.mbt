///|
pub(all) struct Summary {
  records : Int32
  datagrams : Int32
  losses : Int32
  rejected : Int32
  state : @tracker.View
} derive(Debug, Eq, ToJson)

///|
/// Incremental rtnetlink replay. A failed record preserves previous observations,
/// marks the state stale, increments rejected, and raises to the caller.
pub struct Session {
  state : @tracker.State
  mut records : Int32
  mut datagrams : Int32
  mut losses : Int32
  mut rejected : Int32
}

///|
pub fn Session::new() -> Session {
  {
    state: @tracker.State::new(),
    records: 0,
    datagrams: 0,
    losses: 0,
    rejected: 0,
  }
}

///|
pub fn Session::apply(
  self : Session,
  record : @journal.Record,
) -> Unit raise @wire.ProtocolError {
  self.records += 1
  match record {
    @journal.Loss(reason) => {
      self.losses += 1
      self.state.mark_stale(reason)
    }
    @journal.Datagram(data, endian) => {
      self.datagrams += 1
      errdefer {
        self.rejected += 1
      }
      self.state.ingest(data, endian~)
    }
  }
}

///|
/// Feed one JSONL record. Malformed JSON/schema is a rejected, loss-bearing record.
pub fn Session::apply_line(
  self : Session,
  line : String,
) -> Unit raise @wire.ProtocolError {
  let record = {
    errdefer {
      self.records += 1
      self.rejected += 1
      self.state.mark_stale("invalid journal record")
    }
    @journal.parse_line(line)
  }
  self.apply(record)
}

///|
/// Process nonblank lines in order. Earlier complete records survive a later failure.
pub fn Session::feed(
  self : Session,
  text : String,
) -> Unit raise @wire.ProtocolError {
  for line in text.split("\n") {
    let trimmed = line.trim().to_owned()
    if trimmed != "" {
      self.apply_line(trimmed)
    }
  }
}

///|
pub fn Session::summary(self : Session) -> Summary {
  {
    records: self.records,
    datagrams: self.datagrams,
    losses: self.losses,
    rejected: self.rejected,
    state: self.state.view(),
  }
}

///|
pub extend Summary with Debug::{to_repr}

///|
pub extend Summary with Eq::{equal, not_equal}

///|
pub extend Summary with ToJson::{to_json}
