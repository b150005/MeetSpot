import UIKit

final class LocalSearchResultTableViewController: UITableViewController {
  private(set) var places
  
  override func loadView() {
    tableView.register(UITableViewCell.self, forHeaderFooterViewReuseIdentifier: UITableViewCell.normalCellIdentifier)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
}

extension UITableViewCell {
  static let normalCellIdentifier: String = "cell"
}
