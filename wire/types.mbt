///|
/// Byte order of native Netlink integer fields (IP address bytes are separate).
pub(all) enum Endian {
  Little
  Big
} derive(Debug, Eq, ToJson)

///|
pub extend Endian with Eq::{equal, not_equal}

///|
pub extend Endian with Debug::{to_repr}

///|
pub extend Endian with ToJson::{to_json}

///|
pub(all) suberror ProtocolError {
  ProtocolError(String)
} derive(Debug)

///|
pub(all) struct Header {
  kind : Int
  flags : Int
  sequence : UInt
  port : UInt
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Message {
  header : Header
  payload : Bytes
} derive(Debug, Eq, ToJson)

///|
/// raw_kind retains NLA_F_NESTED/NLA_F_NET_BYTEORDER and unknown attribute IDs.
pub(all) struct Attribute {
  raw_kind : Int
  payload : Bytes
} derive(Debug, Eq, ToJson)

///|
pub fn Attribute::kind(self : Attribute) -> Int {
  self.raw_kind & 0x3fff
}

///|
pub fn Attribute::nested(self : Attribute) -> Bool {
  (self.raw_kind & 0x8000) != 0
}

///|
pub fn Attribute::network_order(self : Attribute) -> Bool {
  (self.raw_kind & 0x4000) != 0
}

///|
pub fn Attribute::children(
  self : Attribute,
  endian? : Endian = Little,
) -> Array[Attribute] raise ProtocolError {
  guard self.nested() else {
    raise ProtocolError("attribute is not marked nested")
  }
  decode_attributes(self.payload, endian~)
}

///|
pub extend ProtocolError with Debug::{to_repr}

///|
pub extend Header with Debug::{to_repr}

///|
pub extend Header with Eq::{equal, not_equal}

///|
pub extend Header with ToJson::{to_json}

///|
pub extend Message with Debug::{to_repr}

///|
pub extend Message with Eq::{equal, not_equal}

///|
pub extend Message with ToJson::{to_json}

///|
pub extend Attribute with Debug::{to_repr}

///|
pub extend Attribute with Eq::{equal, not_equal}

///|
pub extend Attribute with ToJson::{to_json}
