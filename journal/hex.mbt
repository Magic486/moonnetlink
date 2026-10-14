///|
/// Stable lowercase hex; journals carry byte order explicitly, not host assumptions.
pub fn hex(data : Bytes) -> String {
  let digits = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f",
  ]
  let parts : Array[String] = []
  for b in data {
    parts.push(digits[b.to_int() >> 4] + digits[b.to_int() & 15])
  }
  parts.join("")
}

///|
fn nibble(c : Char) -> Int raise @wire.ProtocolError {
  match c {
    '0'..='9' => c.to_int() - 48
    'a'..='f' => c.to_int() - 87
    'A'..='F' => c.to_int() - 55
    _ => raise @wire.ProtocolError("invalid hex digit")
  }
}

///|
pub fn unhex(value : String) -> Bytes raise @wire.ProtocolError {
  guard value.length() <= 2097152 else {
    raise @wire.ProtocolError("hex must have even length and be at most 1 MiB")
  }
  let chars = value.to_array()
  guard chars.length() % 2 == 0 else {
    raise @wire.ProtocolError("hex must contain pairs of ASCII digits")
  }
  let bytes : Array[Byte] = []
  for i in 0..<(chars.length() / 2) {
    bytes.push(
      ((nibble(chars[i * 2]) << 4) | nibble(chars[i * 2 + 1])).to_byte(),
    )
  }
  Bytes::from_array(bytes)
}
