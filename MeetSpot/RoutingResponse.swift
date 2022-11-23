import MapKit

struct RoutingResponse {
  let route: MKDirections.Response
  let eta: MKDirections.ETAResponse
  
  init(route: MKDirections.Response, eta: MKDirections.ETAResponse) {
    self.route = route
    self.eta = eta
  }
}
