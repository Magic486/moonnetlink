# Linux transport

Socket/poll/recvmsg bridge with protocol interpretation in MoonBit. Other platforms return unsupported errors.

- `Socket::open()` selects NETLINK_ROUTE; `Socket::open(protocol=Generic)` selects NETLINK_GENERIC.
- dump requires Route and matching successful DONE; family requires Generic and metadata plus successful ACK.
- receive returns None only on timeout; loss and truncation are errors.
- close is idempotent; use defer despite the automatic finalizer.

Queries have deadlines and datagram budgets. Convenience APIs are read-only; raw send is a transport primitive. Generic operation execution and membership helpers are outside this release.

Build cmd/moonnet with target native. Public signatures are in docs/native-api.mbti; documentation generators using WASM may omit native-only interfaces.
