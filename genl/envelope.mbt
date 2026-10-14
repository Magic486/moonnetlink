///|
pub fn decode(
  data : Bytes,
  user_header_size~ : Int32 = 0,
  endian~ : @wire.Endian = @wire.Little,
) -> Envelope raise @wire.ProtocolError {
  guard user_header_size >= 0 &&
    data.length() >= 4 &&
    user_header_size <= data.length() - 4 else {
    raise @wire.ProtocolError("invalid Generic Netlink header size")
  }
  let attributes_offset = 4 + @wire.align4(user_header_size)
  guard attributes_offset <= data.length() else {
    raise @wire.ProtocolError("missing Generic Netlink user header padding")
  }
  {
    command: data[0].to_int(),
    version: data[1].to_int(),
    reserved: @wire.u16(data, 2, endian~),
    user_header: @wire.copy_range(data, 4, user_header_size),
    attributes: @wire.decode_attributes(
      @wire.copy_range(
        data,
        attributes_offset,
        data.length() - attributes_offset,
      ),
      endian~,
    ),
  }
}

///|
pub fn encode(
  envelope : Envelope,
  endian~ : @wire.Endian = @wire.Little,
) -> Bytes raise @wire.ProtocolError {
  guard envelope.command >= 0 &&
    envelope.command <= 255 &&
    envelope.version >= 0 &&
    envelope.version <= 255 else {
    raise @wire.ProtocolError("Generic Netlink command/version out of range")
  }
  guard envelope.user_header.length() <= 1048576 else {
    raise @wire.ProtocolError("Generic Netlink user header budget exceeded")
  }
  let data : FixedArray[Byte] = FixedArray::make(
    4 + @wire.align4(envelope.user_header.length()),
    0,
  )
  data[0] = envelope.command.to_byte()
  data[1] = envelope.version.to_byte()
  @wire.write_u16(data, 2, envelope.reserved, endian~)
  for i in 0..<envelope.user_header.length() {
    data[4 + i] = envelope.user_header[i]
  }
  Bytes::from_array(data) +
  @wire.encode_attributes(envelope.attributes, endian~)
}
