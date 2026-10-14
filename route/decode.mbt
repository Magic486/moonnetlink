///|
fn decode_link(
  data : Bytes,
  endian : @wire.Endian,
) -> Link raise @wire.ProtocolError {
  let attrs = attrs_at(data, 16, endian)
  {
    family: data[0].to_int(),
    hardware_type: @wire.u16(data, 2, endian~),
    index: @wire.i32(data, 4, endian~),
    flags: @wire.u32(data, 8, endian~),
    name: attr_string(attrs, 3),
    mtu: attr_uint(attrs, 4, endian),
    operstate: attr_byte(attrs, 16),
    address: attr_hardware(attrs, 1),
    attributes: attrs,
  }
}

///|
fn decode_address(
  data : Bytes,
  endian : @wire.Endian,
) -> Address raise @wire.ProtocolError {
  let attrs = attrs_at(data, 8, endian)
  let family = data[0].to_int()
  let prefix_length = data[1].to_int()
  validate_prefix(family, prefix_length)
  {
    family,
    prefix_length,
    scope: data[3].to_int(),
    index: @wire.u32(data, 4, endian~),
    flags: attr_uint(attrs, 8, endian).unwrap_or(data[2].to_uint()),
    local_address: attr_ip(attrs, 2, family),
    address: attr_ip(attrs, 1, family),
    label: attr_string(attrs, 3),
    attributes: attrs,
  }
}

///|
fn decode_route(
  data : Bytes,
  endian : @wire.Endian,
) -> Route raise @wire.ProtocolError {
  let attrs = attrs_at(data, 12, endian)
  let family = data[0].to_int()
  let destination_prefix = data[1].to_int()
  let source_prefix = data[2].to_int()
  validate_prefix(family, destination_prefix)
  validate_prefix(family, source_prefix)
  {
    family,
    destination_prefix,
    source_prefix,
    tos: data[3].to_int(),
    table: attr_uint(attrs, 15, endian).unwrap_or(data[4].to_uint()),
    protocol: data[5].to_int(),
    scope: data[6].to_int(),
    route_type: data[7].to_int(),
    flags: @wire.u32(data, 8, endian~),
    destination: attr_ip(attrs, 1, family),
    source: attr_ip(attrs, 2, family),
    gateway: attr_ip(attrs, 5, family),
    output_interface: attr_uint(attrs, 4, endian),
    priority: attr_uint(attrs, 6, endian),
    preferred_source: attr_ip(attrs, 7, family),
    attributes: attrs,
  }
}

///|
fn decode_neighbor(
  data : Bytes,
  endian : @wire.Endian,
) -> Neighbor raise @wire.ProtocolError {
  let attrs = attrs_at(data, 12, endian)
  let family = data[0].to_int()
  {
    family,
    index: @wire.i32(data, 4, endian~),
    state: @wire.u16(data, 8, endian~),
    flags: data[10].to_int(),
    neighbor_type: data[11].to_int(),
    destination: attr_ip(attrs, 1, family),
    lladdr: attr_hardware(attrs, 2),
    attributes: attrs,
  }
}

///|
/// Decode typed events, preserving all original attributes and unknown messages.
pub fn decode(
  message : @wire.Message,
  endian? : @wire.Endian = @wire.Little,
) -> Event raise @wire.ProtocolError {
  let data = message.payload
  match message.header.kind {
    16 | 17 =>
      LinkChanged(decode_link(data, endian), deleted=message.header.kind == 17)
    20 | 21 =>
      AddressChanged(
        decode_address(data, endian),
        deleted=message.header.kind == 21,
      )
    24 | 25 =>
      RouteChanged(
        decode_route(data, endian),
        deleted=message.header.kind == 25,
      )
    28 | 29 =>
      NeighborChanged(
        decode_neighbor(data, endian),
        deleted=message.header.kind == 29,
      )
    2 => Acknowledged(decode_ack(message, endian))
    3 => Done(decode_done(message, endian))
    4 => Overrun
    _ => Unknown(message)
  }
}
