///|
/// Common genlmsghdr plus a family-specific header and the remaining TLVs.
pub(all) struct Envelope {
  command : Int32
  version : Int32
  reserved : Int32
  user_header : Bytes
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Operation {
  id : UInt32
  flags : UInt32
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Group {
  id : UInt32
  name : String
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
/// Controller family metadata. Missing optional capabilities remain None.
pub(all) struct Family {
  id : Int32
  name : String
  version : UInt32?
  header_size : UInt32?
  max_attribute : UInt32?
  operations : Array[Operation]
  groups : Array[Group]
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
pub extend Envelope with Debug::{to_repr}

///|
pub extend Envelope with Eq::{equal, not_equal}

///|
pub extend Envelope with ToJson::{to_json}

///|
pub extend Operation with Debug::{to_repr}

///|
pub extend Operation with Eq::{equal, not_equal}

///|
pub extend Operation with ToJson::{to_json}

///|
pub extend Group with Debug::{to_repr}

///|
pub extend Group with Eq::{equal, not_equal}

///|
pub extend Group with ToJson::{to_json}

///|
pub extend Family with Debug::{to_repr}

///|
pub extend Family with Eq::{equal, not_equal}

///|
pub extend Family with ToJson::{to_json}
