///|
/// Self-authored deterministic fixtures, never confused with live kernel captures.
pub fn link(
  index~ : Int32 = 7,
  name~ : String = "demo0",
  mtu~ : UInt32 = 1500U,
  deleted~ : Bool = false,
  endian~ : @wire.Endian = @wire.Little,
) -> @wire.Message raise @wire.ProtocolError {
  let data : FixedArray[Byte] = FixedArray::make(16, 0)
  @wire.write_u16(data, 2, 1, endian~)
  @wire.write_u32(data, 4, index.reinterpret_as_uint(), endian~)
  @wire.write_u32(data, 8, 1U, endian~)
  let attrs = @wire.encode_attributes(
    [
      { raw_kind: 3, payload: @wire.string_payload(name), },
      { raw_kind: 4, payload: @wire.uint_payload(mtu, endian~), },
      { raw_kind: 16, payload: b"\x06", },
      { raw_kind: 1, payload: b"\x02\x00\x00\x00\x00\x07", },
    ],
    endian~,
  )
  {
    header: {
      kind: if deleted {
        17
      } else {
        16
      },
      flags: 0,
      sequence: 0U,
      port: 0U,
    },
    payload: Bytes::from_array(data) + attrs,
  }
}

///|
pub fn address(
  deleted~ : Bool = false,
) -> @wire.Message raise @wire.ProtocolError {
  let data : FixedArray[Byte] = FixedArray::make(8, 0)
  data[0] = 2
  data[1] = 24
  @wire.write_u32(data, 4, 7U)
  let attrs = @wire.encode_attributes([
    { raw_kind: 1, payload: b"\xc0\x00\x02\x07", },
    { raw_kind: 2, payload: b"\xc0\x00\x02\x07", },
    { raw_kind: 3, payload: b"demo0\x00", },
  ])
  {
    header: {
      kind: if deleted {
        21
      } else {
        20
      },
      flags: 0,
      sequence: 0U,
      port: 0U,
    },
    payload: Bytes::from_array(data) + attrs,
  }
}

///|
pub fn route(
  deleted~ : Bool = false,
) -> @wire.Message raise @wire.ProtocolError {
  let data : FixedArray[Byte] = FixedArray::make(12, 0)
  data[0] = 2
  data[1] = 24
  data[4] = 254
  data[5] = 4
  data[6] = 253
  data[7] = 1
  let attrs = @wire.encode_attributes([
    { raw_kind: 1, payload: b"\xc0\x00\x02\x00", },
    { raw_kind: 4, payload: @wire.uint_payload(7U), },
    { raw_kind: 6, payload: @wire.uint_payload(100U), },
  ])
  {
    header: {
      kind: if deleted {
        25
      } else {
        24
      },
      flags: 0,
      sequence: 0U,
      port: 0U,
    },
    payload: Bytes::from_array(data) + attrs,
  }
}

///|
pub fn neighbor(
  state~ : Int32 = 2,
  mac~ : Bytes = b"\x02\x00\x00\x00\x00\x08",
  deleted~ : Bool = false,
) -> @wire.Message raise @wire.ProtocolError {
  let data : FixedArray[Byte] = FixedArray::make(12, 0)
  data[0] = 2
  @wire.write_u32(data, 4, 7U)
  @wire.write_u16(data, 8, state)
  let attrs = @wire.encode_attributes([
    { raw_kind: 1, payload: b"\xc0\x00\x02\x08", },
    { raw_kind: 2, payload: mac, },
  ])
  {
    header: {
      kind: if deleted {
        29
      } else {
        28
      },
      flags: 0,
      sequence: 0U,
      port: 0U,
    },
    payload: Bytes::from_array(data) + attrs,
  }
}

///|
pub fn control(
  kind : Int32,
  sequence~ : UInt32 = 0U,
  flags~ : Int32 = 0,
  code~ : Int32 = 0,
) -> @wire.Message {
  let payload = if kind == 2 {
    @wire.uint_payload(code.reinterpret_as_uint()) +
    @wire.uint_payload(16U) +
    Bytes::make(12, 0)
  } else if kind == 3 {
    @wire.uint_payload(code.reinterpret_as_uint())
  } else {
    b""
  }
  { header: { kind, flags, sequence, port: 0U, }, payload, }
}

///|
pub fn trace() -> Array[@journal.Record] raise @wire.ProtocolError {
  [
    @journal.Datagram(@wire.encode(link()), @wire.Little),
    @journal.Datagram(@wire.encode(address()), @wire.Little),
    @journal.Datagram(@wire.encode(route()), @wire.Little),
    @journal.Datagram(@wire.encode(neighbor()), @wire.Little),
    @journal.Datagram(@wire.encode(link(mtu=9000U)), @wire.Little),
    @journal.Loss("synthetic ENOBUFS: receiver missed notifications"),
    @journal.Datagram(@wire.encode(link(deleted=true)), @wire.Little),
  ]
}
