//
//  MapViewController.swift
//  MeetSpot
//
//  Created by 伊藤 直輝 on 2022/07/05.
//

import UIKit
import CoreLocation

/// マップモデル(MapModel)とマップ画面(MapView)を紐付けるViewController
final class MapViewController: UIViewController {
  private let notificationCenter: NotificationCenter = NotificationCenter.default
  
  private lazy var mapModel: MapModel = {
    let model: MapModel = MapModel()
    return model
  }()
  
  private lazy var mapView: MapView = {
    let mapView: MapView = MapView()
    return mapView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = mapView
    
    addTargets()
    addObservers()
  }
}

extension MapViewController {
  /// 各Viewをイベントリスナとしてセットする
  private func addTargets() {
    // MapViewの各UIButtonをイベントリスナとしてセット
    mapView.currentLocationButton.addTarget(self, action: #selector(didTapCurrentLocationButton), for: .touchUpInside)
    mapView.specificLocationButton.addTarget(self, action: #selector(didTapSpecificLocationButton), for: .touchUpInside)
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
  
  /// 現在地取得ボタンのタップ時に呼び出される処理
  @objc private func didTapCurrentLocationButton() {
    // アニメーション
    mapView.startAnimation(mapView.currentLocationButton)
    updateCurrentLocationOnce()
  }
  
  /// 地点を指定ボタンのタップ時に呼び出される処理
  @objc private func didTapSpecificLocationButton() {
    // アニメーション
    mapView.startAnimation(mapView.specificLocationButton)
  }
}
