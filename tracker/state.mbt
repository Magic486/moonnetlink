///|
/// Observed objects, not an atomic kernel snapshot. starts_partial always remains true.
pub(all) struct View {
  links : Array[@route.Link]
  addresses : Array[@route.Address]
  routes : Array[@route.Route]
  neighbors : Array[@route.Neighbor]
  stale : Bool
  starts_partial : Bool
  reasons : Array[String]
  applied_events : Int
} derive(Debug, Eq, ToJson)

///|
pub struct State {
  links : Map[Int, @route.Link]
  addresses : Map[String, @route.Address]
  routes : Map[String, @route.Route]
  neighbors : Map[String, @route.Neighbor]
  mut stale : Bool
  reasons : Array[String]
  mut applied_events : Int
} derive(Debug)

///|
pub fn State::new() -> State {
  {
    links: {},
    addresses: {},
    routes: {},
    neighbors: {},
    stale: false,
    reasons: [],
    applied_events: 0,
  }
}

///|
pub fn State::mark_stale(self : State, reason : String) -> Unit {
  self.stale = true
  if !self.reasons.contains(reason) {
    self.reasons.push(reason)
  }
}

///|
fn address_key(a : @route.Address) -> String {
  "\{a.family}/\{a.index}/\{a.prefix_length}/\{a.local_address.unwrap_or("")}/\{a.address.unwrap_or("")}"
}

///|
fn route_key(r : @route.Route) -> String {
  let multipath = match @wire.find_attribute(r.attributes, 9) {
    Some(a) => a.payload
    None => b""
  }
  "\{r.family}/\{r.table}/\{r.destination.unwrap_or("")}/\{r.destination_prefix}/\{r.source.unwrap_or("")}/\{r.source_prefix}/\{r.tos}/\{r.protocol}/\{r.scope}/\{r.route_type}/\{r.priority.unwrap_or(0U)}/\{r.output_interface.unwrap_or(0U)}/\{r.gateway.unwrap_or("")}/\{multipath}"
}

///|
fn neighbor_key(n : @route.Neighbor) -> String {
  "\{n.family}/\{n.index}/\{n.destination.unwrap_or(n.lladdr.unwrap_or(""))}"
}

///|
pub fn State::apply(self : State, event : @route.Event) -> Unit {
  self.applied_events += 1
  match event {
    @route.LinkChanged(link, deleted~) =>
      if deleted {
        self.links.remove(link.index)
        for (key, address) in self.addresses.to_array() {
          if address.index == link.index.reinterpret_as_uint() {
            self.addresses.remove(key)
          }
        }
        for (key, neighbor) in self.neighbors.to_array() {
          if neighbor.index == link.index {
            self.neighbors.remove(key)
          }
        }
        for (key, route) in self.routes.to_array() {
          if route.output_interface == Some(link.index.reinterpret_as_uint()) {
            self.routes.remove(key)
          }
        }
      } else {
        self.links[link.index] = link
      }
    @route.AddressChanged(address, deleted~) => {
      let key = address_key(address)
      if deleted {
        self.addresses.remove(key)
      } else {
        self.addresses[key] = address
      }
    }
    @route.RouteChanged(route, deleted~) => {
      let key = route_key(route)
      if deleted {
        self.routes.remove(key)
      } else {
        self.routes[key] = route
      }
    }
    @route.NeighborChanged(neighbor, deleted~) => {
      let key = neighbor_key(neighbor)
      if deleted {
        self.neighbors.remove(key)
      } else {
        self.neighbors[key] = neighbor
      }
    }
    @route.Overrun => self.mark_stale("Netlink overrun: events lost")
    @route.Acknowledged(ack) | @route.Done(ack) =>
      if ack.code != 0 {
        self.mark_stale("kernel reported failure \{ack.code}")
      }
    @route.Unknown(_) => ()
  }
}

///|
/// Applies a datagram transactionally: malformed later messages cannot apply earlier ones.
pub fn State::ingest(
  self : State,
  data : Bytes,
  endian? : @wire.Endian = @wire.Little,
) -> Unit raise @wire.ProtocolError {
  let messages = @wire.decode(data, endian~)
  let events = messages.map(m => @route.decode(m, endian~))
  for message in messages {
    if (message.header.flags & 0x10) != 0 {
      self.mark_stale("interrupted dump")
    }
  }
  for event in events {
    self.apply(event)
  }
}

///|
/// Returns owned arrays; callers cannot mutate the reducer's maps through this view.
pub fn State::view(self : State) -> View {
  {
    links: self.links.values().to_array(),
    addresses: self.addresses.values().to_array(),
    routes: self.routes.values().to_array(),
    neighbors: self.neighbors.values().to_array(),
    stale: self.stale,
    starts_partial: true,
    reasons: self.reasons.copy(),
    applied_events: self.applied_events,
  }
}

///|
pub extend View with Debug::{to_repr}

///|
pub extend View with Eq::{equal, not_equal}

///|
pub extend View with ToJson::{to_json}

///|
pub extend State with Debug::{to_repr}
