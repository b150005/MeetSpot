@preconcurrency import CoreLocation
@preconcurrency import MapKit

protocol RoutingMapModelInput {
  func currentLocation() async throws -> CLLocation
  func reverseGeocodeLocation(_ location: CLLocation) async throws-> CLPlacemark
//  func requestRoute(_ locations: [MKPlacemark]) async throws -> [MKDirections.Response?]
  func requestLookAroundScene(from coordinate: CLLocationCoordinate2D) async -> MKLookAroundScene?
  func snapshootLookAround(_ scene: MKLookAroundScene?) async -> MKLookAroundSnapshotter.Snapshot?
}

actor RoutingMapModel: NSObject {
  private enum LocationRequestError: Error {
    case noResult
    case restricted
    case denied
    case notFound
    case disabled
    case other(Error)
    
    var error: Error {
      let comment: String = ""
      switch self {
        case .noResult:
          return NSError(domain: NSLocalizedString("noResult", comment: comment), code: -101)
        case .restricted:
          return NSError(domain: NSLocalizedString("locationServicesRestricted", comment: comment), code: -102)
        case .denied:
          return NSError(domain: NSLocalizedString("locationServicesDenied", comment: comment), code: -103)
        case .notFound:
          return NSError(domain: NSLocalizedString("notFoundLocation", comment: comment), code: -104)
        case .disabled:
          return NSError(domain: NSLocalizedString("locationServicesDisabled", comment: comment), code: -105)
        case .other(let error):
          return NSError(domain: error.localizedDescription, code: -110)
      }
    }
  }
  
  private enum LocationRequestResult {
    case success(CLLocation)
    case failure(LocationRequestError)
  }
  
  private enum ReverseGeocodingResult {
    case success(CLPlacemark)
    case failure(Error)
  }
  
  private let geocoder: CLGeocoder = CLGeocoder()
  private let locationManager: CLLocationManager = CLLocationManager()
  
  private var currentLocationResult: LocationRequestResult!
  
  override init() {
    super.init()
    
    Task {
      await configureLocationManager()
      await startUpdating()
    }
  }
  
  deinit {
    Task {
      await stopUpdating()
    }
  }
}

extension RoutingMapModel {
  private func configureLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.allowsBackgroundLocationUpdates = false
    locationManager.distanceFilter = 100
  }
  
  private func startUpdating() {
    switch locationManager.authorizationStatus {
      case .restricted:
        currentLocationResult = .failure(.restricted)
      case .denied:
        currentLocationResult = .failure(.denied)
      case .notDetermined:
        locationManager.requestWhenInUseAuthorization()
      case .authorizedAlways, .authorizedWhenInUse:
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
      @unknown default:
        return
    }
  }
  
  private func stopUpdating() {
    locationManager.stopUpdatingHeading()
    locationManager.stopUpdatingLocation()
  }
  
  private func update(result: LocationRequestResult) {
    self.currentLocationResult = result
  }
}

extension RoutingMapModel: CLLocationManagerDelegate {
  nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    Task {
      guard let lastLocation: CLLocation = locations.last else {
        await update(result: .failure(.notFound))
        return
      }
      await update(result: .success(lastLocation))
    }
  }
  
  nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    Task {
      await update(result: .failure(.other(error)))
    }
  }
  
  nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
      case .authorizedAlways, .authorizedWhenInUse:
        manager.startUpdatingHeading()
        manager.startUpdatingLocation()
      default:
        Task {
          await update(result: .failure(.disabled))
        }
    }
  }
}

extension RoutingMapModel: RoutingMapModelInput {
  func currentLocation() async throws -> CLLocation {
    guard let result = currentLocationResult else {
      throw LocationRequestError.noResult.error
    }
    switch result {
      case .success(let location):
        return location
      case .failure(let requestError):
        throw requestError.error
    }
  }
  
  func reverseGeocodeLocation(_ location: CLLocation) async throws -> CLPlacemark {
    do {
      return try await geocoder.reverseGeocodeLocation(location).first!
    }
    catch {
      throw NSError(domain: NSLocalizedString("reverseGeocodingRequestRateLimited", comment: ""), code: -120)
    }
  }
  
//  func requestRoute(_ locations: [MKPlacemark]) throws -> [MKDirections.Response?] {
//    let request: MKDirections.Request = MKDirections.Request()
//    // placeholder
//    request.source = MKMapItem()
//    request.destination = MKMapItem()
//    request.requestsAlternateRoutes = false
//    request.transportType = .any
//
//    let directions: MKDirections = MKDirections(request: request)
//    return [try await directions.calculate()]
//  }
//
  func requestLookAroundScene(from coordinate: CLLocationCoordinate2D) async -> MKLookAroundScene? {
    do {
      let request: MKLookAroundSceneRequest = MKLookAroundSceneRequest(coordinate: coordinate)
      guard let scene: MKLookAroundScene = try await request.scene else { return nil }
      return scene
    }
    catch {
      return nil
    }
  }
  
  func snapshootLookAround(_ scene: MKLookAroundScene?) async -> MKLookAroundSnapshotter.Snapshot? {
    do {
      guard let scene else { return nil }
      let snapshotter: MKLookAroundSnapshotter = MKLookAroundSnapshotter(scene: scene, options: .init())
      return try await snapshotter.snapshot
    }
    catch {
      return nil
    }
  }
}
