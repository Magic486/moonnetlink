///|
fn main raise {
  let lookup = @genl.Lookup::new(1U, "nlctrl")
  let records = @journal.parse(@fixtures.family_journal_text())
  for record in records {
    guard record is @journal.Datagram(data, endian) else {
      raise @wire.ProtocolError("unexpected loss in controller fixture")
    }
    for message in @wire.decode(data, endian~) {
      if lookup.status() == @genl.Pending {
        ignore(lookup.accept(message, endian~))
      }
    }
  }
  let json : Json = {
    "source": "recorded-linux-controller",
    "family": lookup.result().to_json(),
    "metadata_and_ack_complete": true,
  }
  println(json.stringify())
}
