///|
fn main raise {
  let state = @tracker.State::new()
  for step, record in @scenarios.trace() {
    // Serialize then parse: exercise the exact public journal boundary.
    match @journal.parse_line(@journal.line(record)) {
      @journal.Datagram(data, endian) => state.ingest(data, endian~)
      @journal.Loss(reason) => state.mark_stale(reason)
    }
    let view = state.view()
    let json : Json = {
      "source": "synthetic-demo",
      "step": step,
      "links": view.links.length(),
      "addresses": view.addresses.length(),
      "routes": view.routes.length(),
      "neighbors": view.neighbors.length(),
      "stale": view.stale,
      "reasons": view.reasons,
    }
    println(json.stringify())
  }
}
