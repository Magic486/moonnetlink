# Incremental rtnetlink replay

`Session::new()` accepts typed journal records with `apply`, one JSONL line with `apply_line`, or ordered text with `feed`. Summaries contain record/datagram/loss/rejection counts and an owned observation view.

Malformed records raise and mark stale while preserving prior observations. Malformed datagrams apply no event from that datagram. Later valid input does not clear stale. Earlier complete lines survive a later failure in feed.

This session interprets rtnetlink. Generic recordings need the corresponding decoder/transaction; v1 logs do not identify protocol automatically. CLI family-replay handles one controller query.

Changing summary arrays does not change session state. Immutable Bytes are shared safely. No Linux or filesystem dependency is required.
