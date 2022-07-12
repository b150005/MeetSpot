//
//  MapViewController.swift
//  MeetSpot
//
//  Created by 伊藤 直輝 on 2022/07/05.
//

import UIKit
import CoreLocation

/// マップ画面(MapView)のViewController
final class MapViewController: UIViewController, CLLocationManagerDelegate {
  private lazy var mapView: MapView = MapView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
  }
}

extension MapViewController {
  private func setupViews() {
    view = mapView
    
    // MapViewの各UIButtonをイベントリスナとしてセット
    mapView.currentLocationButton.addTarget(self, action: #selector(touchesCurrentLocationButton), for: .touchUpInside)
    mapView.specificLocationButton.addTarget(self, action: #selector(touchesSpecificLocationButton), for: .touchUpInside)
  }
  
  /// 現在地取得ボタンを押下した際に呼び出される処理
  @objc func touchesCurrentLocationButton() {
    // アニメーション
    mapView.startAnimation(mapView.currentLocationButton)
  }
  
  /// 地点を指定ボタンを押下した際に呼び出される処理
  @objc func touchesSpecificLocationButton() {
    // アニメーション
    mapView.startAnimation(mapView.specificLocationButton)
  }
}
