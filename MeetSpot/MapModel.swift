//
//  MapModel.swift
//  MeetSpot
//
//  Created by 伊藤 直輝 on 2022/07/05.
//

import CoreLocation
import MapKit

final class MapModel: NSObject {
  private let notificationCenter: NotificationCenter = NotificationCenter.default
  var departureCoordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
  var centerCoordinates: CLLocationCoordinate2D?
  
  lazy var locationManager: CLLocationManager = {
    let manager: CLLocationManager = CLLocationManager()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    return manager
  }()
  
  var isLocationServiceEnabled: Bool {
    return CLLocationManager.locationServicesEnabled()
  }
  
  func updateCurrentLocation() {
    switch locationManager.authorizationStatus {
      case .authorizedAlways, .authorizedWhenInUse:
        locationManager.requestLocation()
      default:
        locationManager.requestWhenInUseAuthorization()
    }
  }
}

extension MapModel: CLLocationManagerDelegate {
  /// 現在地の更新時に呼び出される処理
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let lastLocation: CLLocation = locations.last else { return }
    let coordinate: CLLocationCoordinate2D = lastLocation.coordinate
    
    departureCoordinates.append(coordinate)
    notificationCenter.post(name: .didUpdateCurrentLocation, object: nil, userInfo: ["coordinate": coordinate])
    
    print(lastLocation)
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
