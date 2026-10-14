///|
pub(all) enum ObjectKind {
  Links
  Addresses
  Routes
  Neighbors
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Link {
  index : Int32
  family : Int32
  hardware_type : Int32
  flags : UInt32
  name : String?
  mtu : UInt32?
  operstate : Int32?
  address : String?
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Address {
  index : UInt32
  family : Int32
  prefix_length : Int32
  flags : UInt32
  scope : Int32
  local_address : String?
  address : String?
  label : String?
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Route {
  family : Int32
  destination_prefix : Int32
  source_prefix : Int32
  tos : Int32
  table : UInt32
  protocol : Int32
  scope : Int32
  route_type : Int32
  flags : UInt32
  destination : String?
  source : String?
  gateway : String?
  output_interface : UInt32?
  priority : UInt32?
  preferred_source : String?
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Neighbor {
  family : Int32
  index : Int32
  state : Int32
  flags : Int32
  neighbor_type : Int32
  destination : String?
  lladdr : String?
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
/// Kernel errno is signed and negative on failure; zero is a successful ACK.
pub(all) struct Ack {
  code : Int32
  message : String?
  bad_offset : UInt32?
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
pub(all) enum Event {
  LinkChanged(Link, deleted~ : Bool)
  AddressChanged(Address, deleted~ : Bool)
  RouteChanged(Route, deleted~ : Bool)
  NeighborChanged(Neighbor, deleted~ : Bool)
  Acknowledged(Ack)
  Done(Ack)
  Overrun
  Unknown(@wire.Message)
} derive(Debug, Eq, ToJson)

///|
pub extend ObjectKind with Debug::{to_repr}

///|
pub extend ObjectKind with Eq::{equal, not_equal}

///|
pub extend ObjectKind with ToJson::{to_json}

///|
pub extend Link with Debug::{to_repr}

///|
pub extend Link with Eq::{equal, not_equal}

///|
pub extend Link with ToJson::{to_json}

///|
pub extend Address with Debug::{to_repr}

///|
pub extend Address with Eq::{equal, not_equal}

///|
pub extend Address with ToJson::{to_json}

///|
pub extend Route with Debug::{to_repr}

///|
pub extend Route with Eq::{equal, not_equal}

///|
pub extend Route with ToJson::{to_json}

///|
pub extend Neighbor with Debug::{to_repr}

///|
pub extend Neighbor with Eq::{equal, not_equal}

///|
pub extend Neighbor with ToJson::{to_json}

///|
pub extend Ack with Debug::{to_repr}

///|
pub extend Ack with Eq::{equal, not_equal}

///|
pub extend Ack with ToJson::{to_json}

///|
pub extend Event with Debug::{to_repr}

///|
pub extend Event with Eq::{equal, not_equal}

///|
pub extend Event with ToJson::{to_json}
