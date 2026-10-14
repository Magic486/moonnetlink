///|
fn main raise {
  let state = @tracker.State::new()
  for step, record in @journal.parse(@fixtures.journal_text()) {
    match record {
      @journal.Datagram(data, endian) => state.ingest(data, endian~)
      @journal.Loss(reason) => state.mark_stale(reason)
    }
    let view = state.view()
    let json : Json = {
      "source": "recorded-linux-kernel",
      "step": step,
      "links": view.links.map(link => link.name.unwrap_or("unknown")),
      "addresses": view.addresses.map(a => {
        a.local_address.unwrap_or(a.address.unwrap_or(""))
      }),
      "route_count": view.routes.length(),
      "neighbor_count": view.neighbors.length(),
      "stale": view.stale,
      "applied_events": view.applied_events,
    }
    println(json.stringify())
  }
}
