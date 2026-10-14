///|
#borrow(path)
extern "C" fn read_raw(path : Bytes) -> Bytes = "mn_read_file"

///|
#borrow(path, data)
extern "C" fn write_raw(path : Bytes, data : Bytes, append : Bool) -> Int = "mn_write_file"

///|
pub extern "C" fn exit(code : Int) -> Unit = "mn_exit"

///|
fn path_bytes(path : String) -> Bytes raise NativeError {
  guard !path.contains("\u0000") else {
    raise NativeError("NUL in file path", 22)
  }
  @utf8.encode(path) + b"\x00"
}

///|
pub fn read_text(path : String) -> String raise {
  @utf8.decode(unwrap_frame(read_raw(path_bytes(path))))
}

///|
pub fn write_text(
  path : String,
  data : String,
  append? : Bool = false,
) -> Unit raise {
  let status = write_raw(path_bytes(path), @utf8.encode(data), append)
  guard status == 0 else { raise NativeError("write file", -status) }
}

///|
#borrow(data)
extern "C" fn stderr_raw(data : Bytes) -> Unit = "mn_stderr"

///|
pub fn write_stderr(value : String) -> Unit {
  stderr_raw(@utf8.encode(value))
}

///|
pub extern "C" fn flush_stdout() -> Unit = "mn_flush"
