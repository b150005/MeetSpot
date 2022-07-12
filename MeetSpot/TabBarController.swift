//
//  TabBarController.swift
//  MeetSpot
//
//  Created by 伊藤 直輝 on 2022/07/04.
//

import UIKit

/// 各画面共通のTabBarController
final class TabBarController: UITabBarController {
  /// 読込直後に呼び出される処理
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.delegate = self
    
    setupTabBar()
  }
  
  /// TabBarを初期化する
  private func setupTabBar() {
    // MARK: - Initialize ViewController
    let mapVC: MapViewController = MapViewController()
    
    // MARK: - Add Tab Items
    let mapTabBarItem: UITabBarItem = UITabBarItem(title: "見つける", image: UIImage(systemName: "figure.wave"), tag: 0)
    mapVC.tabBarItem = mapTabBarItem
    
    // MARK: - Add a Static Drop-Shadow to UITabBar
    let tabBarLayer: CALayer = self.tabBar.layer
    tabBarLayer.shadowColor = UIColor.black.cgColor
    tabBarLayer.shadowOffset = CGSize(width: 0, height: -2)
    tabBarLayer.shadowRadius = 2
    tabBarLayer.shadowOpacity = 0.15
    
    // MARK: - UITabBarAppearance
    if #available(iOS 13.0, *) {
      let customAppearance: UITabBarAppearance = UITabBarAppearance()
      customAppearance.configureWithDefaultBackground()
      customAppearance.backgroundColor = .clear
      
      let appearance: UITabBar = UITabBar.appearance()
      appearance.standardAppearance = customAppearance
      
      if #available(iOS 15.0, *) {
        appearance.scrollEdgeAppearance = customAppearance
      }
    }
    
    self.viewControllers = [mapVC]
  }
}

extension TabBarController: UITabBarControllerDelegate {
  
}
