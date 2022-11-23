import UIKit
import MapKit

/// MapViewに追加したアノテーションをリスト形式で表示するTableViewController
@MainActor
final class AnnotationTableViewController: UITableViewController {
  /// アノテーションリスト
  private var annotations: [MKAnnotation]?
  
  /// 現在地の更新をViewControllerに通知する`NotificationCenter`
  private let notificationCenter: NotificationCenter = NotificationCenter.default
  
  init(annotations: [MKAnnotation], style: UITableView.Style = .plain) {
    super.init(style: style)
    
    // UITableView ⇄ UITableViewCell の紐付け
    registerCell()
    
    self.annotations = annotations
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
    guard let annotations else { return 0 }
    return annotations.count
  }
  
  /// TableViewの各セルを定義する
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
    
    guard let title: String = annotations?[indexPath.row].title ?? nil else { return cell }
    
    var content: UIListContentConfiguration = cell.defaultContentConfiguration()
    content.text = title
    cell.contentConfiguration = content
    
    return cell
  }
  
  /// セルの編集を有効にする
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  /// セル編集時の処理を定義する
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                          forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // NotificationCenterにアノテーションの削除を通知
      notificationCenter.post(
        name: .didDeleteAnnotation,
        object: nil,
        userInfo: [UserInfoKeys.removedAnnotation : annotations?[indexPath.row] as Any]
      )
      
      annotations?.remove(at: indexPath.row)
      
      // TableViewのアノテーションを削除
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
}

extension AnnotationTableViewController {
  /// TableViewに表示するTableViewCellを登録する
  private func registerCell() {
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
  }
}

extension Notification.Name {
  static let didDeleteAnnotation: Notification.Name = Notification.Name("AnnotationTableViewController.editingStyle.delete")
}
