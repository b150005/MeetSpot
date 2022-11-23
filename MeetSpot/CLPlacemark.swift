import CoreLocation

extension CLPlacemark {
  var annotationTitle: String? {
    get {
      guard let thoroughfare, let subThoroughfare else {
        var title: String = ""
        title += administrativeArea ?? ""
        title += subAdministrativeArea ?? ""
        title += locality ?? ""
        title += subLocality ?? ""
        return title
      }
      return thoroughfare + subThoroughfare
    }
  }
}
