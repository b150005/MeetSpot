import UIKit
import MapKit

/// MapViewのプレゼンテーションロジックを扱うView
final class MapView: UIView {
  // MARK: - Constants
  private struct Constants {
    static let currentLocationButtonImageName: String = "location.fill"
    static let annotationListButtonImageName: String = "list.bullet"
    
    static let routingButtonTitle: String = "移動時間が等しい中間地点を検索する"
    static let routingButtonBackgroundColor: UIColor = .white
    
    static let viewConstraint: CGFloat = 15
    static let zoomInDelta: CGFloat = 0.005
  }
  
  // MARK: - Views
  /// 画面全体に表示するマップ
  private lazy var mapView: MKMapView = {
    let mapView: MKMapView = MKMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    mapView.isPitchEnabled = true
    mapView.isRotateEnabled = true
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
    mapView.mapType = .standard
    
    mapView.register(
      MarkerAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
    )

    return mapView
  }()
  
  /// 現在地の2D座標を取得するボタン
  private lazy var currentLocationButton: FloatingActionButton = {
    let button: FloatingActionButton = FloatingActionButton(systemName: Constants.currentLocationButtonImageName)
    
    // Constraints
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setNeedsUpdateConstraints()
    
    return button
  }()
  
  /// MapViewのアノテーションリストを表示するボタン
  private lazy var annotationListButton: FloatingActionButton = {
    let button: FloatingActionButton = FloatingActionButton(systemName: Constants.annotationListButtonImageName)
    
    // Constraints
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setNeedsUpdateConstraints()
    
    return button
  }()
  
  private lazy var routingButton: UIButton = {
    let button: FloatingActionButton = FloatingActionButton(title: "wow")
    
    // Constraints
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setNeedsUpdateConstraints()
    
    return button
  }()
  
  // MARK: - Alert
  static let temporaryErrorAlert: UIAlertController = {
    let alert: UIAlertController = UIAlertController(
      title: "Error",
      message: "Temporary error has occurred."
               + "\n"
               + "Please try again later.",
      preferredStyle: .alert
    )
    let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default)
    alert.addAction(okAction)
    
    return alert
  }()
  
  static let locationServiceDisabledAlert: UIAlertController = {
    let settingsURL: URL = URL(string: UIApplication.openSettingsURLString)!
    
    let alert:UIAlertController = UIAlertController(
      title: "Settings",
      message: "To get your current Location, enable Location Services"
              + "\n"
              + "Settings > Privacy > Location Service",
      preferredStyle: .alert
    )
    let yesAction: UIAlertAction = UIAlertAction(title: "OK", style: .default)
    let settingsAction: UIAlertAction = UIAlertAction(title: "Settings", style: .default,
                                                      handler: {(alert: UIAlertAction) -> Void in
      let application: UIApplication = UIApplication.shared
      if application.canOpenURL(settingsURL) == true {
        application.open(settingsURL)
      }
    })
    alert.addAction(yesAction)
    alert.addAction(settingsAction)
    
    return alert
  }()
  
  // MARK: - Constructor
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    mapView.delegate = self
    
    addSubViews()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    mapView.delegate = self
    
    addSubViews()
  }
  
  // MARK: - Override Methods
  /// 制約の更新
  override func updateConstraints() {
    super.updateConstraints()
    
    NSLayoutConstraint.activate([
      currentLocationButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.viewConstraint),
      currentLocationButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.viewConstraint * 8)
    ])
    NSLayoutConstraint.activate([
      annotationListButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.viewConstraint),
      annotationListButton.bottomAnchor.constraint(equalTo: currentLocationButton.topAnchor, constant: -Constants.viewConstraint)
    ])
    NSLayoutConstraint.activate([
      routingButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      routingButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 80)
    ])
  }
}

// MARK: - Extension
extension MapView {
  /// MapViewのマップビューを取得する
  /// - returns: MapViewの`MKMapView`オブジェクト
  func getMapView() -> MKMapView {
    return self.mapView
  }
  
  /// MapViewの現在地取得ボタンを取得する
  /// - returns: MapViewの現在地取得を行う`FloatingActionButton`オブジェクト
  func getCurrentLocationButton() -> FloatingActionButton {
    return self.currentLocationButton
  }
  
  /// MapViewのアノテーションリスト表示ボタンを取得する
  /// - returns: MapViewのアノテーション一覧を表示する`FloatingActionButton`オブジェクト
  func getAnnotationListButton() -> FloatingActionButton {
    return self.annotationListButton
  }
  
  /// サブViewの追加
  private func addSubViews() {
    addSubview(mapView)
    addSubview(currentLocationButton)
    addSubview(annotationListButton)
    addSubview(routingButton)
  }
  
  /// タップ時のUIButtonアニメーション
  /// - parameter button: タップされるボタン
  func startAnimation(_ button: UIButton) {
    // TODO: - Pulse Animationの実装
    UIView.animate(withDuration: 0.6, delay: 0, options: .curveLinear, animations: {() -> Void in
      button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      button.alpha = 0.85
      
      button.transform = CGAffineTransform(scaleX: 1, y: 1)
      button.alpha = 1
    }, completion: nil)
  }
  
  /// 指定地点をズームインして表示する
  /// - parameter coordinate: ズームイン時に画面中央に表示される2D座標
  func zoomInMapView(_ coordinate: CLLocationCoordinate2D) {
    let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: Constants.zoomInDelta, longitudeDelta: Constants.zoomInDelta)
    let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
    
    mapView.setRegion(region, animated: true)
  }
  
  /// マップにアノテーションを追加する
  /// - parameter annotation: 2D座標と地名情報をもつアノテーション
  func addAnnotation(_ annotation: Annotation) {
    mapView.addAnnotation(annotation)
  }
  
  /// MapView上でタップされた地点の2D座標を取得する
  /// - parameter tappedPoint: 画面スクリーン上の2D座標
  /// - returns: タップされた地点の2D座標
  func convertTapPointIntoCoordinate2D(_ tappedPoint: CGPoint) -> CLLocationCoordinate2D {
    return mapView.convert(tappedPoint, toCoordinateFrom: mapView)
  }
  
  /// MapViewにジェスチャーを追加する
  /// - parameter recognizer: `UIGestureRecognizer`のサブクラスであるジェスチャー認識クラス
  func addGestureRecognizerToMapView<T: UIGestureRecognizer>(_ recognizer: T) {
    mapView.addGestureRecognizer(recognizer)
  }
  
  /// MapViewのアノテーションを取得する
  /// - returns: MapViewのアノテーション
  func fetchAnnotations() -> [Annotation]? {
    guard let annotations: [Annotation] = mapView.annotations as? [Annotation] else { return nil }
    return annotations
  }
}

// TODO: - MKMapViewDelegate
extension MapView: MKMapViewDelegate {
  /// MapViewに追加するアノテーションを作成する
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier: String = MKMapViewDefaultAnnotationViewReuseIdentifier
    
    var markerAnnotationView: MarkerAnnotationView
    
    if let customAnnotationView: MarkerAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MarkerAnnotationView {
      customAnnotationView.annotation = annotation
      markerAnnotationView = customAnnotationView
    }
    else {
      let defaultMarkerAnnotationView: MarkerAnnotationView = MarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      markerAnnotationView = defaultMarkerAnnotationView
    }
    
    return markerAnnotationView
  }
  
  /// アノテーションのAccessoryボタンをタップした際の処理
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if let cluster = view.annotation as? MKClusterAnnotation {
      mapView.removeAnnotations(cluster.memberAnnotations)
    }
    else {
      guard let annotation: MKAnnotation = view.annotation else { return }
      mapView.removeAnnotation(annotation)
    }
  }
}
