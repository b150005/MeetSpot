import UIKit

/// 各画面共通のTabBarController
@MainActor
final class TabBarController: UITabBarController {
  /// Viewのロード時に呼び出される処理
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.delegate = self
    
    initializeTabBar()
  }
  
  /// TabBarを初期化する
  private func initializeTabBar() {
    let tabBarItemTag: Int = 0
    
    let mapTabBarItem: UITabBarItem = UITabBarItem(
      title: NSLocalizedString("mapTitle", comment: ""),
      image: UIImage(systemName: "figure.wave"),
      tag: tabBarItemTag)
    let bookmarkTabBarItem: UITabBarItem = UITabBarItem(
      title: NSLocalizedString("bookmarkTitle", comment: ""),
      image: UIImage(systemName: "bookmark.fill"),
      tag: tabBarItemTag)
    
    let mapVC: RoutingMapViewController = RoutingMapViewController()
    let mapModel: RoutingMapModel = RoutingMapModel()
    let mapPresenter: RoutingMapPresenterInput = RoutingMapPresenter(view: mapVC, model: mapModel)
    mapVC.inject(mapPresenter)
    
    let bookmarkVC: BookmarkViewController = BookmarkViewController()
    
    mapVC.tabBarItem = mapTabBarItem
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
