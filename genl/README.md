# Generic Netlink discovery

Portable Generic Netlink envelope and nlctrl metadata codecs for WASM-GC, JS and native. Linux transport is in `Magic486/moonnetlink/native`.

`family_request(name, seq)` builds read-only CTRL_CMD_GETFAMILY with REQUEST|ACK. `decode_family(message, endian=...)` returns ID/name, optional version/header-size/max-attribute, operations and multicast groups. Unknown TLVs and legacy unflagged nests are preserved.

`Lookup::new(seq, name)` accepts replies; `result()` requires metadata AND successful ACK. Replies may arrive in either order; mismatched names, errors, duplicates and interruption fail permanently. Other sequences are ignored before decoding.

Envelope encode/decode support an aligned family-specific header. Arbitrary operations, policy introspection and multicast membership are outside this release.

Run `moon run examples/family_replay --target wasm-gc`; Linux also supports `moon run cmd/moonnet --target native -- family nlctrl`.
