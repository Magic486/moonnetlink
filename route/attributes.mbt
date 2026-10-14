///|
fn attrs_at(
  data : Bytes,
  offset : Int,
  endian : @wire.Endian,
) -> Array[@wire.Attribute] raise @wire.ProtocolError {
  @wire.decode_attributes(
    @wire.copy_range(data, offset, data.length() - offset),
    endian~,
  )
}

///|
fn attr_uint(
  attrs : Array[@wire.Attribute],
  kind : Int,
  endian : @wire.Endian,
) -> UInt? raise @wire.ProtocolError {
  match @wire.find_attribute(attrs, kind) {
    None => None
    Some(a) => {
      guard a.payload.length() == 4 else {
        raise @wire.ProtocolError("attribute \{kind} requires u32")
      }
      let order = if a.network_order() { @wire.Big } else { endian }
      Some(@wire.u32(a.payload, 0, endian=order))
    }
  }
}

///|
fn attr_byte(
  attrs : Array[@wire.Attribute],
  kind : Int,
) -> Int? raise @wire.ProtocolError {
  match @wire.find_attribute(attrs, kind) {
    None => None
    Some(a) => {
      guard a.payload.length() == 1 else {
        raise @wire.ProtocolError("attribute \{kind} requires byte")
      }
      Some(a.payload[0].to_int())
    }
  }
}

///|
fn attr_string(
  attrs : Array[@wire.Attribute],
  kind : Int,
) -> String? raise @wire.ProtocolError {
  match @wire.find_attribute(attrs, kind) {
    None => None
    Some(a) => Some(@wire.cstring(a.payload))
  }
}

///|
fn hex_byte(b : Byte) -> String {
  let digits = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f",
  ]
  digits[b.to_int() >> 4] + digits[b.to_int() & 15]
}

///|
pub fn hardware_address(data : Bytes) -> String {
  let parts : Array[String] = []
  for b in data {
    parts.push(hex_byte(b))
  }
  parts.join(":")
}

///|
/// Formats IPv6 without compression; integer byte order does not affect IP bytes.
pub fn ip_address(
  data : Bytes,
  family : Int,
) -> String raise @wire.ProtocolError {
  match family {
    2 => {
      guard data.length() == 4 else {
        raise @wire.ProtocolError("IPv4 requires four bytes")
      }
      data.to_array().map(b => b.to_int().to_string()).join(".")
    }
    10 => {
      guard data.length() == 16 else {
        raise @wire.ProtocolError("IPv6 requires sixteen bytes")
      }
      let parts : Array[String] = []
      for i in 0..<8 {
        parts.push(hex_byte(data[i * 2]) + hex_byte(data[i * 2 + 1]))
      }
      parts.join(":")
    }
    _ => hardware_address(data)
  }
}

///|
fn attr_ip(
  attrs : Array[@wire.Attribute],
  kind : Int,
  family : Int,
) -> String? raise @wire.ProtocolError {
  match @wire.find_attribute(attrs, kind) {
    None => None
    Some(a) => Some(ip_address(a.payload, family))
  }
}

///|
fn attr_hardware(attrs : Array[@wire.Attribute], kind : Int) -> String? {
  match @wire.find_attribute(attrs, kind) {
    None => None
    Some(a) => Some(hardware_address(a.payload))
  }
}

///|
fn validate_prefix(
  family : Int,
  length : Int,
) -> Unit raise @wire.ProtocolError {
  guard (family != 2 || length <= 32) && (family != 10 || length <= 128) else {
    raise @wire.ProtocolError("IP prefix out of range")
  }
}
