///|
/// One Linux rtnexthop. Weight is rtnh_hops + 1; unknown per-hop TLVs survive.
pub(all) struct NextHop {
  index : Int32
  flags : Int32
  weight : Int32
  gateway : String?
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
/// Decode RTA_MULTIPATH payload; each rtnexthop has its own length and alignment.
pub fn decode_next_hops(
  data : Bytes,
  family : Int32,
  endian~ : @wire.Endian = @wire.Little,
) -> Array[NextHop] raise @wire.ProtocolError {
  let result : Array[NextHop] = []
  let mut offset = 0
  while offset < data.length() {
    let remaining = data.length() - offset
    guard remaining >= 8 else {
      raise @wire.ProtocolError("truncated rtnexthop header")
    }
    let length = @wire.u16(data, offset, endian~)
    guard length >= 8 && length <= remaining else {
      raise @wire.ProtocolError("invalid rtnexthop length")
    }
    let attributes = @wire.decode_attributes(
      @wire.copy_range(data, offset + 8, length - 8),
      endian~,
    )
    result.push({
      index: @wire.i32(data, offset + 4, endian~),
      flags: data[offset + 2].to_int(),
      weight: data[offset + 3].to_int() + 1,
      gateway: attr_ip(attributes, 5, family),
      attributes,
    })
    let aligned = @wire.align4(length)
    guard aligned <= remaining || length == remaining else {
      raise @wire.ProtocolError("truncated rtnexthop padding")
    }
    offset += if aligned <= remaining { aligned } else { length }
  }
  result
}

///|
/// Missing multipath attribute returns an empty list. Pass the original message endian.
pub fn Route::next_hops(
  self : Route,
  endian~ : @wire.Endian = @wire.Little,
) -> Array[NextHop] raise @wire.ProtocolError {
  match @wire.find_attribute(self.attributes, 9) {
    None => []
    Some(attribute) => decode_next_hops(attribute.payload, self.family, endian~)
  }
}

///|
pub extend NextHop with Debug::{to_repr}

///|
pub extend NextHop with Eq::{equal, not_equal}

///|
pub extend NextHop with ToJson::{to_json}
