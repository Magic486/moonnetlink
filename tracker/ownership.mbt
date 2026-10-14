///|
fn own_link(link : @route.Link) -> @route.Link {
  { ..link, attributes: link.attributes.copy(), }
}

///|
fn own_address(address : @route.Address) -> @route.Address {
  { ..address, attributes: address.attributes.copy(), }
}

///|
fn own_route(route : @route.Route) -> @route.Route {
  { ..route, attributes: route.attributes.copy(), }
}

///|
fn own_neighbor(neighbor : @route.Neighbor) -> @route.Neighbor {
  { ..neighbor, attributes: neighbor.attributes.copy(), }
}
