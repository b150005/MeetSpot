//
//  MapView.swift
//  MeetSpot
//
//  Created by 伊藤 直輝 on 2022/07/05.
//

import UIKit
import MapKit

final class MapView: UIView {
  // MARK: - Constants
  private static let borderWidth: CGFloat = 0.3
  private static let shadowOffset: CGSize = CGSize(width: 2, height: 2)
  private static let shadowRadius: CGFloat = 2
  private static let shadowOpacity: Float = 0.15
  private static let FABLength: CGFloat = 56
  private static let viewConstraint: CGFloat = 15
  
  // MARK: - Views
  /// 画面全体に表示するマップ
  lazy var mapView: MKMapView = {
    let mapView: MKMapView = MKMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    mapView.isPitchEnabled = true
    mapView.isRotateEnabled = true
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
    mapView.mapType = .standard
    
    mapView.register(
      AnnotationView.self,
      forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
    )

    return mapView
  }()
  
  /// 現在地の2D座標を取得するボタン
  lazy var currentLocationButton: UIButton = {
    let button: UIButton = UIButton(type: .custom)
    
    // Constraints
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setNeedsUpdateConstraints()
    
    // Frame Size
    button.setNeedsLayout()
    
    // Icon & Interaction
    button.setImage(UIImage(systemName: "location.fill"), for: .normal)
    button.backgroundColor = .white
    button.tintColor = .systemBlue
    
    // Border
    button.layer.borderColor = UIColor.gray.cgColor
    button.layer.borderWidth = MapView.borderWidth
    
    // Shadow
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = MapView.shadowOffset
    button.layer.shadowRadius = MapView.shadowRadius
    button.layer.shadowOpacity = MapView.shadowOpacity
    
    return button
  }()
  
  /// 指定地点の2D座標を取得するボタン
  lazy var specificLocationButton: UIButton = {
    let button: UIButton = UIButton(type: .custom)
    
    // Constraints
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setNeedsUpdateConstraints()
    
    // Frame Size
    button.setNeedsLayout()
    
    // Icon & Interaction
    button.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
    button.backgroundColor = .white
    button.tintColor = .systemBlue
    
    // Border
    button.layer.borderColor = UIColor.gray.cgColor
    button.layer.borderWidth = MapView.borderWidth
    
    // Shadow
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = MapView.shadowOffset
    button.layer.shadowRadius = MapView.shadowRadius
    button.layer.shadowOpacity = MapView.shadowOpacity
    
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
    
    addSubViews()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubViews()
  }
  
  // MARK: - Override Methods
  /// 制約の更新
  override func updateConstraints() {
    NSLayoutConstraint.activate([
      currentLocationButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -MapView.viewConstraint),
      currentLocationButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -MapView.viewConstraint * 8),
      currentLocationButton.widthAnchor.constraint(equalToConstant: MapView.FABLength),
      currentLocationButton.heightAnchor.constraint(equalToConstant: MapView.FABLength)
    ])
    NSLayoutConstraint.activate([
      specificLocationButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -MapView.viewConstraint),
      specificLocationButton.bottomAnchor.constraint(equalTo: currentLocationButton.topAnchor, constant: -MapView.viewConstraint),
      specificLocationButton.widthAnchor.constraint(equalToConstant: MapView.FABLength),
      specificLocationButton.heightAnchor.constraint(equalToConstant: MapView.FABLength)
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
  
  /// タップ時のUIButtonアニメーション
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
  func zoomInMapView(_ coordinate: CLLocationCoordinate2D) {
    let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
    
    mapView.setRegion(region, animated: true)
  }
  
  /// マップにピンを設置する
  func dropAnnotation(_ coordinate: CLLocationCoordinate2D) {
//    let annotation: 
  }
}
