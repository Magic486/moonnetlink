///|
pub(all) enum Record {
  Datagram(Bytes, @wire.Endian)
  Loss(String)
} derive(Debug, Eq)

///|
/// JSONL version 1 has a per-record endianness field, avoiding cross-host drift.
pub fn line(record : Record) -> String {
  let json : Json = match record {
    Datagram(data, endian) =>
      {
        "version": 1,
        "kind": "datagram",
        "endian": if endian == @wire.Little {
          "little"
        } else {
          "big"
        },
        "hex": hex(data),
      }
    Loss(reason) => { "version": 1, "kind": "loss", "reason": reason }
  }
  json.stringify()
}

///|
pub fn parse_line(value : String) -> Record raise @wire.ProtocolError {
  let json = @json.parse(value) catch {
    _ => raise @wire.ProtocolError("invalid journal JSON")
  }
  match json {
    {
      "version": 1,
      "kind": "datagram",
      "endian": String(order),
      "hex": String(raw),
      ..
    } => {
      let endian = match order {
        "little" => @wire.Little
        "big" => @wire.Big
        _ => raise @wire.ProtocolError("unknown journal endian")
      }
      Datagram(unhex(raw), endian)
    }
    { "version": 1, "kind": "loss", "reason": String(reason), .. } =>
      Loss(reason)
    _ => raise @wire.ProtocolError("unsupported journal version or record")
  }
}

///|
pub fn parse(value : String) -> Array[Record] raise @wire.ProtocolError {
  let records : Array[Record] = []
  for line in value.split("\n") {
    let trimmed = line.trim().to_owned()
    if trimmed != "" {
      records.push(parse_line(trimmed))
    }
  }
  records
}

///|
pub extend Record with Debug::{to_repr}

///|
pub extend Record with Eq::{equal, not_equal}
