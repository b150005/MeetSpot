import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  /// アプリケーションの起動直前に呼び出される処理
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // UIWindow ⇄ UIViewControllerの紐付け
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = TabBarController()
    // UIWindowの表示
    window?.makeKeyAndVisible()
    
    return true
  }
}

