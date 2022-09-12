import CoreLocation
import MapKit

/// MapViewのビジネスロジックを扱うModel
final class MapModel: NSObject {
  // MARK: - Constants
  private struct Constants {
    /// 現在地の更新時に`NotificationCenter`が通知する辞書のキー
    static let coordinateUserInfoKey: String = "coordinate"
  }
  
  /// 現在地の更新をViewControllerに通知する`NotificationCenter`
  private let notificationCenter: NotificationCenter = NotificationCenter.default
  
  /// ジオコーディングを行う`CLGeoCoder`
  private let geocoder: CLGeocoder = CLGeocoder()
  
  /// 現在地を取得する`CLLocationManager`
  private lazy var locationManager: CLLocationManager = {
    let manager: CLLocationManager = CLLocationManager()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    return manager
  }()
  
  /// 位置情報サービスが有効になっているかどうかを表すフラグ
  var isLocationServiceEnabled: Bool {
    return CLLocationManager.locationServicesEnabled()
  }
  
  /// MapViewに追加されたアノテーションの配列
  private var annotations: [Annotation] = [Annotation]()
}

extension MapModel {
  /// 現在地を更新する
  func updateCurrentLocation() {
    switch locationManager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      locationManager.requestLocation()
    default:
      locationManager.requestWhenInUseAuthorization()
    }
  }
  
  /// 逆ジオコーディングによって地点情報を取得する
  /// - parameter location: 逆ジオコーディング対象の2D座標を持つ`CLLocation`オブジェクト
  /// - returns: 地名を含む`CLPlacemark`オブジェクト(地点取得に失敗した場合は`nil`を返却)
  func reverseGeocodeLocation (_ location: CLLocation) async -> CLPlacemark? {
    do {
      guard let placemark: CLPlacemark = try await geocoder.reverseGeocodeLocation(location).first else { return nil }
      return placemark
    }
    catch {
      // 逆ジオコーディング中にエラーが発生した場合
      return nil
    }
  }
}

extension MapModel: CLLocationManagerDelegate {
  /// 現在地の更新時に呼び出される処理
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let lastLocation: CLLocation = locations.last else { return }
    let coordinate: CLLocationCoordinate2D = lastLocation.coordinate
    
    notificationCenter.post(
      name: .didUpdateCurrentLocation,
      object: nil,
      userInfo: [Constants.coordinateUserInfoKey: coordinate])
  }
  
  /// 現在地の取得に失敗した場合に呼び出される処理
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    notificationCenter.post(name: .didFailWithError, object: nil)
  }
  
  /// 位置情報サービスの利用権限が変更された場合に呼び出される処理
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      manager.requestLocation()
    default:
      return
    }
  }
}

extension Notification.Name {
  /// 現在地更新の通知
  static let didUpdateCurrentLocation: Notification.Name = Notification.Name("MapModel.didUpdateCurrentLocation")
  /// 現在地取得エラーの通知
  static let didFailWithError: Notification.Name = Notification.Name("MapModel.didFailWithError")
}

extension CLPlacemark {
  /// returns an abbreviated name from the place
  /// - returns: a user-friendly description of the place containing the name of the place or its address
  func description() -> String {
    let defaultDescription: String = "Unknown Place"
    
    if let name: String = name { return name }
    else if let thoroughfare: String = thoroughfare, let subThoroughfare: String = subThoroughfare {
      return thoroughfare + subThoroughfare
    }
    else if let subLocality: String = subLocality { return subLocality }
    else if let locality: String = locality { return locality }
    else if let country: String = country { return country }
    else { return defaultDescription }
  }
}
