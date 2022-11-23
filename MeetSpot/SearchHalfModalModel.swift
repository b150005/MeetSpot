import CoreLocation
import MapKit

protocol SearchHalfModalModelInput {
  var localSearchCompleter: MKLocalSearchCompleter { get }
  
  func calculateETAIntermediateSpot(from coordinate: CLLocationCoordinate2D) async -> [RoutingResponse]?
  func updateSearchRegion(center: CLLocationCoordinate2D, radius: CLLocationDistance)
  @MainActor func extractFilter(from tokens: [UISearchToken]) -> MKPointOfInterestFilter
  func searchLocation(from query: String?, in filter: MKPointOfInterestFilter) async -> [MKLocalSearchCompletion]?
  func geocodeAddress(from query: String) async -> MKPointAnnotation?
  func createSearchToken(from indexPath: IndexPath) async -> UISearchToken
}

final class SearchHalfModalModel: NSObject, SearchHalfModalModelInput {
  private var hasUpdatedLocationSearchResults: Bool = false
  
  lazy var localSearchCompleter: MKLocalSearchCompleter = {
    let completer: MKLocalSearchCompleter = MKLocalSearchCompleter()
    completer.delegate = self
    completer.resultTypes = .query
    return completer
  }()
  
  func calculateETAIntermediateSpot(from coordinate: CLLocationCoordinate2D) async -> [RoutingResponse]? {
    // TODO: - 中間地点の検索方法
    return nil
  }
  
  func updateSearchRegion(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
    let newRegion: MKCoordinateRegion = MKCoordinateRegion(center: center,
                                                           latitudinalMeters: radius,
                                                           longitudinalMeters: radius)
    localSearchCompleter.region = newRegion
  }
  
  @MainActor
  func extractFilter(from tokens: [UISearchToken]) -> MKPointOfInterestFilter {
    var categories: [MKPointOfInterestCategory] = [MKPointOfInterestCategory]()
    
    for token in tokens {
      guard let category: MKPointOfInterestCategory = token.representedObject as? MKPointOfInterestCategory
      else { continue }
      categories.append(category)
    }
    return MKPointOfInterestFilter(including: categories)
  }
  
  func searchLocation(from query: String?, in filter: MKPointOfInterestFilter) async -> [MKLocalSearchCompletion]? {
    localSearchCompleter.pointOfInterestFilter = filter
    hasUpdatedLocationSearchResults = false
    
    guard let query, query.isEmpty == true else { return nil }
    localSearchCompleter.queryFragment = query
    
    if (hasUpdatedLocationSearchResults == true) {
      return localSearchCompleter.results
    }
    else {
      return nil
    }
  }
  
  func geocodeAddress(from query: String) async -> MKPointAnnotation? {
    let geocoder: CLGeocoder = CLGeocoder()
    
    do {
      guard let placemark: CLPlacemark = try await geocoder.geocodeAddressString(query).first,
            let location: CLLocation = placemark.location
      else { return nil }
      
      let annotation: MKPointAnnotation = MKPointAnnotation()
      annotation.coordinate = location.coordinate
      annotation.title = query
      
      return annotation
    }
    catch {
      return nil
    }
  }
  
  func createSearchToken(from indexPath: IndexPath) async -> UISearchToken {
    let filter: (key: String, value: MKPointOfInterestCategory) = FilteringCategories.categories.elements[indexPath.row]
    let token: UISearchToken = await UISearchToken(icon: nil, text: filter.key)
    
    Task { @MainActor in
      token.representedObject = filter.value
    }
    
    return token
  }
}

extension SearchHalfModalModel: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    hasUpdatedLocationSearchResults = true
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    hasUpdatedLocationSearchResults = false
  }
}
