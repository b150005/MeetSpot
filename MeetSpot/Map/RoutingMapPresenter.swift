@preconcurrency import CoreLocation
@preconcurrency import MapKit

@MainActor
protocol RoutingMapPresenterInput {
  func didLongPressRoutingMap(_ location: CLLocation)
  func didTapRoutingButton()
  func didTapCurrentLocationButton()
  func didTapAnnotationListButton(_ annotations: [MKPointAnnotation])
  func didTapLookAroundView()
}

@MainActor
protocol RoutingMapPresenterOutput: AnyObject {
  func addAnnotation(_ annotation: MKPointAnnotation)
  
  func updateLookAroundView(scene: MKLookAroundScene?, snapshot: MKLookAroundSnapshotter.Snapshot?)
  
  func transitionToLookAround()
  
  func updateRoutingHalfModal()
  
  func showAnnotationList()
  
  func moveToCenter(_ coordinate: CLLocationCoordinate2D, animated: Bool)
  
  func showError(message: String, canMoveToSettings: Bool)
}

@MainActor
final class RoutingMapPresenter {
  private weak var view: RoutingMapPresenterOutput!
  private var model: RoutingMapModelInput
  
  init(view: RoutingMapPresenterOutput, model: RoutingMapModelInput) {
    self.view = view
    self.model = model
  }
}

extension RoutingMapPresenter: RoutingMapPresenterInput {
  func didLongPressRoutingMap(_ location: CLLocation) {
    Task {
      do {
        let placemark: CLPlacemark = try await model.reverseGeocodeLocation(location)
        
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = placemark.annotationTitle
        
        view.addAnnotation(annotation)
        
        let scene: MKLookAroundScene? = await model.requestLookAroundScene(from: location.coordinate)
        let snapshot: MKLookAroundSnapshotter.Snapshot? = await model.snapshootLookAround(scene)
        view.updateLookAroundView(scene: scene, snapshot: snapshot)
      }
      catch {
        let error: NSError = error as NSError
        view.showError(message: error.domain, canMoveToSettings: false)
      }
    }
  }
  
  func didTapLookAroundView() {
    view.transitionToLookAround()
  }
  
  func didTapRoutingButton() {
    
  }
  
  func didTapCurrentLocationButton() {
    Task {
      do {
        let currentLocation: CLLocation = try await model.currentLocation()
        view.moveToCenter(currentLocation.coordinate, animated: true)
      }
      catch {
        let error: NSError = error as NSError
        var canMoveToSettings: Bool = false
        switch error.code {
          case -102, -103, -105:
            canMoveToSettings = true
          default:
            canMoveToSettings = false
        }
        view.showError(message: error.domain, canMoveToSettings: canMoveToSettings)
      }
    }
  }
  
  func didTapAnnotationListButton(_ annotations: [MKPointAnnotation]) {
    view.showAnnotationList()
  }
}
