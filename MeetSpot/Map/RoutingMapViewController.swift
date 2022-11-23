import UIKit
import MapKit

@MainActor
final class RoutingMapViewController: UIViewController {
  private var presenter: RoutingMapPresenterInput!
  
  private let notificationCenter: NotificationCenter = NotificationCenter.default
  
  private let mapView: MKMapView = MKMapView()
  
  private let routingButton: FloatingActionButton = FloatingActionButton(title: NSLocalizedString("routingTitle", comment: ""))
  
  private let currentLocationButton: FloatingActionButton = FloatingActionButton(image: UIImage(systemName: "location.fill"))
  
  private let annotationListButton: FloatingActionButton = FloatingActionButton(image: UIImage(systemName: "list.bullet"))
  
  override func loadView() {
    mapView.delegate = self
    view = mapView
    
    configureNotificationCenter()
    configureMapView()
    configureRoutingButton()
    configureCurrentLocationButton()
    configureAnnotationListButton()
    
    view.addSubview(currentLocationButton)
    view.addSubview(annotationListButton)
    view.addSubview(routingButton)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
    
    NSLayoutConstraint.activate([
      mapView.widthAnchor.constraint(equalToConstant: view.frame.width),
      mapView.heightAnchor.constraint(equalToConstant: view.frame.height)
    ])
    
    NSLayoutConstraint.activate([
      currentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.defaultConstraint),
      currentLocationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.defaultConstraint * 8)
    ])
    
    NSLayoutConstraint.activate([
      annotationListButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.defaultConstraint),
      annotationListButton.bottomAnchor.constraint(equalTo: currentLocationButton.topAnchor, constant: -Constants.defaultConstraint)
    ])
    
    NSLayoutConstraint.activate([
      routingButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
      routingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      routingButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.defaultConstraint * 5)
    ])
  }
}

extension RoutingMapViewController {
  func inject(_ presenter: RoutingMapPresenterInput) {
    self.presenter = presenter
  }
  
  private func configureNotificationCenter() {
    notificationCenter.addObserver(self, selector: #selector(removeAnnotation(from:)), name: .didDeleteAnnotation, object: nil)
  }
  
  @objc private func removeAnnotation(from notification: NSNotification?) {
    guard let notification,
          let userInfo = notification.userInfo,
          let annotation: MKAnnotation = userInfo[UserInfoKeys.removedAnnotation] as? MKAnnotation
    else { return }
    mapView.removeAnnotation(annotation)
  }
  
  private func configureMapView() {
    mapView.isRotateEnabled = true
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
    mapView.showsCompass = true
    mapView.showsUserLocation = true
    mapView.setUserTrackingMode(.followWithHeading, animated: true)
    mapView.selectableMapFeatures = [.pointsOfInterest]
    
    let configuration: MKStandardMapConfiguration = MKStandardMapConfiguration(elevationStyle: .flat, emphasisStyle: .default)
    configuration.showsTraffic = true
    mapView.preferredConfiguration = configuration
    
    mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    
    mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMapView)))
    
    mapView.translatesAutoresizingMaskIntoConstraints = false
    mapView.setNeedsUpdateConstraints()                                                                       
  }
  
  private func configureCurrentLocationButton() {
    currentLocationButton.addAction(UIAction() { [weak self] _ in
      guard let self else { return }
      self.presenter.didTapCurrentLocationButton()
    }, for: .primaryActionTriggered)
    
    currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
    currentLocationButton.setNeedsUpdateConstraints()
  }
  
  private func configureRoutingButton() {
    routingButton.addAction(UIAction() { [weak self] _ in
      guard let self else { return }
      self.presenter.didTapRoutingButton()
    }, for: .primaryActionTriggered)
    
    routingButton.translatesAutoresizingMaskIntoConstraints = false
    routingButton.setNeedsUpdateConstraints()
  }
  
  private func configureAnnotationListButton() {
    annotationListButton.addAction(UIAction() { [weak self] _ in
      guard let self else { return }
      self.presenter.didTapAnnotationListButton(self.annotations())
    }, for: .primaryActionTriggered)
    
    annotationListButton.translatesAutoresizingMaskIntoConstraints = false
    annotationListButton.setNeedsUpdateConstraints()
  }
  
  private func annotations() -> [MKPointAnnotation] {
    return mapView.annotations.map {
      let annotation: MKPointAnnotation = MKPointAnnotation()
      annotation.coordinate = $0.coordinate
      annotation.title = $0.title ?? ""
      return annotation
    }
  }
  
  @objc private func didLongPressMapView(_ gesture: UILongPressGestureRecognizer) {
    guard gesture.state == .began else { return }
    
    let coordinate: CLLocationCoordinate2D = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)
    let location: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    presenter.didLongPressRoutingMap(location)
  }
}

// MARK: - MKMapViewDelegate
extension RoutingMapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier: String = MKMapViewDefaultAnnotationViewReuseIdentifier
    let clusteringIdentifier: String = "clustering"
    
    var view: MKMarkerAnnotationView
    if let _view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
      _view.annotation = annotation
      view = _view
    }
    else {
      view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
    }
    
    view.sizeToFit()
    view.canShowCallout = true
    view.clusteringIdentifier = clusteringIdentifier
    view.animatesWhenAdded = true
    view.titleVisibility = .visible
    view.subtitleVisibility = .visible
    
    let button: UIButton = UIButton(type: .detailDisclosure, primaryAction: UIAction() { _ in
      if let cluster: MKClusterAnnotation = view.annotation as? MKClusterAnnotation {
        mapView.removeAnnotations(cluster.memberAnnotations)
      }
      else {
        mapView.removeAnnotation(annotation)
      }
    })
    button.setImage(UIImage(systemName: "trash"), for: .normal)
    view.rightCalloutAccessoryView = button
    
    guard let feature: MKMapFeatureAnnotation = annotation as? MKMapFeatureAnnotation,
          let icon: MKIconStyle = feature.iconStyle
    else { return view }
    let imageView: UIImageView = UIImageView(image: icon.image.withTintColor(icon.backgroundColor, renderingMode: .alwaysOriginal))
    view.leftCalloutAccessoryView = imageView
    
    return view
  }
}

// MARK: - RoutingMapPresenterOutput
extension RoutingMapViewController: RoutingMapPresenterOutput {
  func addAnnotation(_ annotation: MKPointAnnotation) {
    mapView.addAnnotation(annotation)
  }
  
  func showLookAroundScene(_ scene: MKLookAroundScene) {
    
  }
  
  func transitionToLookAround(_ scene: MKLookAroundScene) {
    
  }
  
  func updateRoutingHalfModal() {
    
  }
  
  func showAnnotationList() {
    let annotationListVC: AnnotationTableViewController = AnnotationTableViewController(annotations: mapView.annotations)
//    navigationController?.pushViewController(annotationListVC, animated: true)
    present(annotationListVC, animated: true)
  }
  
  func moveToCenter(_ coordinate: CLLocationCoordinate2D, animated: Bool) {
    mapView.setCenter(coordinate, animated: animated)
  }
  
  func showError(message: String, canMoveToSettings: Bool) {
    present(Alert.controller(title: NSLocalizedString("error", comment: ""),
                             message: message,
                             preferredStyle: .actionSheet,
                             canMoveToSettings: canMoveToSettings),
            animated: true)
  }
}
