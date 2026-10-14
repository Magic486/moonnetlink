///|
pub(all) enum ObjectKind {
  Links
  Addresses
  Routes
  Neighbors
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Link {
  index : Int
  family : Int
  hardware_type : Int
  flags : UInt
  name : String?
  mtu : UInt?
  operstate : Int?
  address : String?
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Address {
  index : UInt
  family : Int
  prefix_length : Int
  flags : UInt
  scope : Int
  local_address : String?
  address : String?
  label : String?
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Route {
  family : Int
  destination_prefix : Int
  source_prefix : Int
  tos : Int
  table : UInt
  protocol : Int
  scope : Int
  route_type : Int
  flags : UInt
  destination : String?
  source : String?
  gateway : String?
  output_interface : UInt?
  priority : UInt?
  preferred_source : String?
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Neighbor {
  family : Int
  index : Int
  state : Int
  flags : Int
  neighbor_type : Int
  destination : String?
  lladdr : String?
  attributes : Array[@wire.Attribute]
} derive(Debug, Eq, ToJson)

///|
/// Kernel errno is signed and negative on failure; zero is a successful ACK.
pub(all) struct Ack {
  code : Int
  message : String?
  bad_offset : UInt?
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
