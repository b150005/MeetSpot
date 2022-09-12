//
//  Annotation+AnnotationView.swift
//  MeetSpot
//
//  Created by 伊藤 直輝 on 2022/07/29.
//

import UIKit
import MapKit

/// MapViewに表示するアノテーションを保持するクラス
class Annotation: NSObject, MKAnnotation {
  /// アノテーションの2D座標
  let coordinate: CLLocationCoordinate2D
  /// アノテーションの地名を表すタイトル
  let title: String?
  
  init(_ coordinate: CLLocationCoordinate2D, title: String?) {
    self.coordinate = coordinate
    self.title = title
    
    super.init()
  }
}

/// MapViewに表示するアノテーションビュー
final class MarkerAnnotationView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      // プロパティの値を操作
      canShowCallout = true
      titleVisibility = .visible
      subtitleVisibility = .hidden
      
      // アノテーション群をクラスタ化する
      let identifier: String = "clusteringIdentifier"
      clusteringIdentifier = identifier
      
      // アクセサリビューの画像を変更
      let accessoryButton: UIButton = UIButton(type: .detailDisclosure)
      accessoryButton.setImage(UIImage(systemName: "trash"), for: .normal)
      rightCalloutAccessoryView = accessoryButton
    }
  }
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
