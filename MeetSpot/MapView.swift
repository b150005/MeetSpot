//
//  MapView.swift
//  MeetSpot
//
//  Created by 伊藤 直輝 on 2022/07/05.
//

import UIKit
import MapKit
import Floaty

final class MapView: UIView {
  /// MapView
  lazy var mapView: MKMapView = {
    let mapView: MKMapView = MKMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    mapView.isPitchEnabled = true
    mapView.isRotateEnabled = true
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
    mapView.mapType = .standard

    return mapView
  }()
  
  /// 現在地の2D座標を取得するボタン
  lazy var currentLocationButton: UIButton = {
    let button: UIButton = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setNeedsUpdateConstraints()
    button.setNeedsLayout()
    button.setImage(UIImage(systemName: "location.fill"), for: .normal)
    button.backgroundColor = .white
    button.tintColor = .systemBlue
    button.layer.borderColor = UIColor.gray.cgColor
    button.layer.borderWidth = 0.3
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 2, height: 2)
    button.layer.shadowRadius = 2
    button.layer.shadowOpacity = 0.15
    return button
  }()
  
  /// 指定地点の2D座標を取得するボタン
  lazy var specificLocationButton: UIButton = {
    let button: UIButton = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setNeedsUpdateConstraints()
    button.setNeedsLayout()
    button.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
    button.backgroundColor = .white
    button.tintColor = .systemBlue
    button.layer.borderColor = UIColor.gray.cgColor
    button.layer.borderWidth = 0.3
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 2, height: 2)
    button.layer.shadowRadius = 2
    button.layer.shadowOpacity = 0.15
    return button
  }()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    addSubViews()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubViews()
  }
  
  /// 制約の更新
  override func updateConstraints() {
    NSLayoutConstraint.activate([
      currentLocationButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
      currentLocationButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -115),
      currentLocationButton.widthAnchor.constraint(equalToConstant: 56),
      currentLocationButton.heightAnchor.constraint(equalToConstant: 56)
    ])
    NSLayoutConstraint.activate([
      specificLocationButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
      specificLocationButton.bottomAnchor.constraint(equalTo: currentLocationButton.topAnchor, constant: -15),
      specificLocationButton.widthAnchor.constraint(equalToConstant: 56),
      specificLocationButton.heightAnchor.constraint(equalToConstant: 56)
    ])
    
    super.updateConstraints()
  }
  
  /// `UIView#frame`の更新
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // UIButtonを丸くする
    currentLocationButton.layer.cornerRadius = currentLocationButton.frame.width / 2
    specificLocationButton.layer.cornerRadius = specificLocationButton.frame.width / 2
  }
}

extension MapView {
  /// サブViewの追加
  private func addSubViews() {
    // MARK: - Add views
    addSubview(mapView)
    addSubview(currentLocationButton)
    addSubview(specificLocationButton)
  }
  
  /// タップ時のUIButtonアニメーション(Pulse Animation)
  func startAnimation(_ button: UIButton) {
    UIView.animate(withDuration: 0.6, delay: 0, options: .curveLinear, animations: {() -> Void in
      button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      button.alpha = 0.85
      
      button.transform = CGAffineTransform(scaleX: 1, y: 1)
      button.alpha = 1
    }, completion: nil)
  }
}
