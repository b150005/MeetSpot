import UIKit

/// 各画面共通のTabBarController
final class TabBarController: UITabBarController {
  // MARK: - Constants
  /// `TabBarController`の定数を定義する列挙体
  private struct Constants {
    /// `MapViewController`の`UITabBarItem`の`title`
    static let mapTitle: String = "見つける"
    /// `BookmarkViewController`のTabBarItemの`title`
    static let bookmarkTitle: String = "お気に入り"
    
    /// `MapViewController`の`UITabBarItem`の`image`
    static let mapImageName: String = "figure.wave"
    /// `BookmarkViewController`の`UITabBarItem`の`image`
    static let bookmarkImageName: String = "bookmark.fill"
    
    /// `UITabBarItem`の`tag`
    static let itemTag: Int = 0
    
    /// `UITabBar`の`shadowColor`
    static let shadowColor: CGColor = UIColor.black.cgColor
    /// `UITabBar`の`shadowOffset`
    static let shadowOffset: CGSize = CGSize(width: 0, height: -2)
    /// `UITabBar`の`shadowRadius`
    static let shadowRadius: CGFloat = 2
    /// `UITabBar`の`shadowOpacity`
    static let shadowOpacity: Float = 0.15
    
    static let backgroundColor: UIColor = .clear
  }
  
  /// Viewのロード時に呼び出される処理
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.delegate = self
    
    initializeTabBar()
  }
  
  /// TabBarを初期化する
  private func initializeTabBar() {
    let mapVC: MapViewController = MapViewController()
    let bookmarkVC: BookmarkViewController = BookmarkViewController()
    
    let mapTabBarItem: UITabBarItem = UITabBarItem(
      title: Constants.mapTitle,
      image: UIImage(systemName: Constants.mapImageName),
      tag: Constants.itemTag)
    mapVC.tabBarItem = mapTabBarItem
    let bookmarkTabBarItem: UITabBarItem = UITabBarItem(
      title: Constants.bookmarkTitle,
      image: UIImage(systemName: Constants.bookmarkImageName),
      tag: Constants.itemTag)
    bookmarkVC.tabBarItem = bookmarkTabBarItem
    
    let tabBarLayer: CALayer = self.tabBar.layer
    tabBarLayer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
    tabBarLayer.shadowColor = Constants.shadowColor
    tabBarLayer.shadowOffset = Constants.shadowOffset
    tabBarLayer.shadowRadius = Constants.shadowRadius
    tabBarLayer.shadowOpacity = Constants.shadowOpacity
    
    if #available(iOS 13.0, *) {
      let customAppearance: UITabBarAppearance = UITabBarAppearance()
      customAppearance.configureWithDefaultBackground()
      customAppearance.backgroundColor = Constants.backgroundColor
      
      let appearance: UITabBar = UITabBar.appearance()
      appearance.standardAppearance = customAppearance
      
      if #available(iOS 15.0, *) {
        appearance.scrollEdgeAppearance = customAppearance
      }
    }
    
    self.viewControllers = [mapVC, bookmarkVC]
  }
}

extension TabBarController: UITabBarControllerDelegate {
  
}
