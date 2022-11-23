import UIKit

@MainActor
struct Alert: Sendable {
  private static let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default)
  private static let settingsAction: UIAlertAction = UIAlertAction(
                                                    title: NSLocalizedString("settings", comment: ""),
                                                    style: .default) { (alert: UIAlertAction) -> Void in
    let application: UIApplication = UIApplication.shared
    let settingsURL: URL = URL(string: UIApplication.openSettingsURLString)!
    
    if application.canOpenURL(settingsURL) == true {
      application.open(settingsURL)
    }
  }
  
  static func controller(title: String,
                              message: String,
                              preferredStyle: UIAlertController.Style,
                              canMoveToSettings: Bool) -> UIAlertController {
    let alert: UIAlertController = UIAlertController(title: title,
                                                     message: message,
                                                     preferredStyle: preferredStyle)
    alert.addAction(okAction)
    
    if canMoveToSettings {
      alert.addAction(settingsAction)
    }
    
    return alert
  }
}
