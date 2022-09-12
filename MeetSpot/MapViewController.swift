import UIKit
import CoreLocation

/// マップモデル(MapModel)とマップ画面(MapView)を紐付けるViewController
final class MapViewController: UIViewController {
  /// MapModelから通知を受け取る`NotificationCenter`
  private let notificationCenter: NotificationCenter = NotificationCenter.default
  
  /// ビジネスロジックを扱うModel
  private lazy var mapModel: MapModel = {
    let model: MapModel = MapModel()
    return model
  }()
  
  /// プレゼンテーションロジックを扱うView
  private lazy var mapView: MapView = {
    let mapView: MapView = MapView()
    return mapView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = mapView
    
    addTargets()
    addObservers()
    addTapGestureRecognizer()
  }
}

extension MapViewController {
  /// 各Viewをイベントリスナとしてセットする
  private func addTargets() {
    // MapViewの各UIButtonをイベントリスナとしてセット
    mapView.getCurrentLocationButton().addTarget(self, action: #selector(didTapCurrentLocationButton), for: .touchUpInside)
    mapView.getAnnotationListButton().addTarget(self, action: #selector(didTapAnnotationListButton), for: .touchUpInside)
  }
  
  /// NotificationCenterから通知を受信した際の処理を定義する
  private func addObservers() {
    // 現在地をズームして表示
    notificationCenter.addObserver(
      forName: .didUpdateCurrentLocation,
      object: nil,
      queue: OperationQueue.main,
      using: { [weak self] (notification: Notification) -> Void in
        guard let coordinate: CLLocationCoordinate2D = notification.userInfo?["coordinate"] as? CLLocationCoordinate2D else { return }
        self?.mapView.zoomInMapView(coordinate)
      }
    )
    
    // 現在地の更新に失敗した場合はエラーダイアログを表示
    notificationCenter.addObserver(
      forName: .didFailWithError,
      object: nil,
      queue: OperationQueue.main,
      using: { [weak self] (notification: Notification) -> Void in
        self?.present(MapView.temporaryErrorAlert, animated: true)
      })
  }
  
  /// Viewにジェスチャーを追加する
  private func addTapGestureRecognizer() {
    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(didTapMapView(_:))
    )
    let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(
      target: self,
      action: #selector(didLongPressMapView(_:))
    )
    
    mapView.addGestureRecognizerToMapView(tapGesture)
    mapView.addGestureRecognizerToMapView(longPressGesture)
  }
  
  /// 現在地を1回だけ取得する
  private func updateCurrentLocationOnce() {
    // 位置情報サービスが無効の場合は設定画面への遷移を促すダイアログを表示
    if mapModel.isLocationServiceEnabled == false {
      present(MapView.locationServiceDisabledAlert, animated: true)
    }
    else {
      mapModel.updateCurrentLocation()
    }
  }
  
  /// アノテーションの一覧を表示するTableViewControllerに遷移する
  /// - parameter mapView: アノテーションを保持するMapView
  private func segueAnnotationTableViewController(_ mapView: MapView) {
    var annotationTableVC: AnnotationTableViewController
    
    if let annotations: [Annotation] = mapView.fetchAnnotations() {
      annotationTableVC = AnnotationTableViewController(annotations: annotations)
    }
    else {
      annotationTableVC = AnnotationTableViewController(annotations: nil)
    }
    
    present(annotationTableVC, animated: true)
  }
  
  /// 現在地取得ボタンのタップ時に呼び出される処理
  @objc private func didTapCurrentLocationButton() {
    // アニメーション
    mapView.startAnimation(mapView.getCurrentLocationButton())
    
    // 現在地の取得
    updateCurrentLocationOnce()
  }
  
  /// アノテーションリスト表示ボタンのタップ時に呼び出される処理
  @objc private func didTapAnnotationListButton() {
    // アニメーション
    mapView.startAnimation(mapView.getAnnotationListButton())
    
    // AnnotationTableViewControllerに遷移
    segueAnnotationTableViewController(mapView)
  }
  
  /// MapView上でのタップ時に呼び出される処理
  @objc private func didTapMapView(_ gesture: UITapGestureRecognizer) {
    guard gesture.state == .ended else { return }
  }
  
  /// MapView上での長押し時に呼び出される処理
  @objc private func didLongPressMapView(_ gesture: UILongPressGestureRecognizer) {
    guard gesture.state == .began else { return }
    
    // 長押しした地点をマップの中心にする
    let point: CGPoint = gesture.location(in: mapView.getMapView())
    let coordinate: CLLocationCoordinate2D = mapView.convertTapPointIntoCoordinate2D(point)
    mapView.zoomInMapView(coordinate)
    
    // 長押しした地点の逆ジオコーディング
    let location: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    Task {
      guard let placemark: CLPlacemark = await mapModel.reverseGeocodeLocation(location) else { return }
      
      // アノテーションを追加する
      let title: String = placemark.description()
      let annotation: Annotation = Annotation(coordinate, title: title)
      mapView.addAnnotation(annotation)
    }
  }
}
