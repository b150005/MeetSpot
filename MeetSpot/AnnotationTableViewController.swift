//
//  AnnotationTableViewController.swift
//  MeetSpot
//
//  Created by 伊藤 直輝 on 2022/08/12.
//

import UIKit

/// MapViewに追加したアノテーションをリスト形式で表示するTableViewController
final class AnnotationTableViewController: UITableViewController {
  private var annotations: [Annotation]?
  
  init(annotations: [Annotation]?, style: UITableView.Style = .plain) {
    super.init(style: style)
    
    guard let annotations: [Annotation] = annotations else { return }
    self.annotations = annotations
    
    // UITableView ⇄ UITableViewCell の紐付け
    registerCell()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    self.annotations = [Annotation]()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  // MARK: - Table view data source
  /// TableViewに表示するセクション数を取得する
  /// - parameter tableView: `UITableView`
  /// - returns: セクション数
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  /// TableViewに表示する行数を取得する
  /// - parameters:
  ///  - tableView: `UITableView`
  ///  - section: セクション番号
  /// - returns: セクションあたりに表示するセル数
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let annotations = annotations else { return 0 }
    
    return annotations.count
  }
  
  /// TableViewの各セルを定義する
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
    
    guard let annotations: [Annotation] = annotations, let title: String = annotations[indexPath.row].title else { return cell }
    var content: UIListContentConfiguration = cell.defaultContentConfiguration()
    content.text = title
    cell.contentConfiguration = content
    
    return cell
  }
  
  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
}

extension AnnotationTableViewController {
  /// TableViewに表示するTableViewCellを登録する
  private func registerCell() {
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
  }
}
