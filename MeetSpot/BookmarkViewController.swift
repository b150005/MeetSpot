//
//  BookmarkViewController.swift
//  MeetSpot
//
//  Created by 伊藤 直輝 on 2022/07/12.
//

import UIKit

final class BookmarkViewController: UITableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    layoutTableView()
    registerCell()
  }
  
  /// TableViewのセクション数を取得する
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  /// TableViewのセクションあたりの行数を取得する
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: BookmarkCardViewCell = tableView.dequeueReusableCell(withIdentifier: "cardViewCell", for: indexPath) as! BookmarkCardViewCell
    return cell
  }
  
  /// TableViewCellの想定の高さを動的に取得する
  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 200
  }
  
  /// TableViewCellの実際の高さを動的に取得する
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 200
  }
  
  /// TableViewCellののタップ時に呼び出される処理
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("Tapped")
  }
}

extension BookmarkViewController {
  /// TableViewに表示するTableViewCellを登録する
  private func registerCell() {
    self.tableView.register(BookmarkCardViewCell.self, forCellReuseIdentifier: "cardViewCell")
  }
  
  /// TableViewのレイアウトを設定する
  private func layoutTableView() {
    tableView.separatorStyle = .none
  }
}
