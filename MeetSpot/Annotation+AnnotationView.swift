//
//  Annotation+AnnotationView.swift
//  MeetSpot
//
//  Created by 伊藤 直輝 on 2022/07/29.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
  let title: String?
  let coordinate: CLLocationCoordinate2D
  
  init(title: String?, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.coordinate = coordinate
    
    super.init()
  }
}

final class AnnotationView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      guard let annotation = newValue as? Annotation else { return }
      
      canShowCallout = true
      rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
  }
}
