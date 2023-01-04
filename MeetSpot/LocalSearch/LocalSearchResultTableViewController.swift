import UIKit
import MapKit

final class LocalSearchResultTableViewController: UITableViewController {
  private var presenter: LocalSearchPresenterInput!
  
//  override func loadView() {
//    tableView.register(UITableViewCell.self, forHeaderFooterViewReuseIdentifier: UITableViewCell.defaultCellIdentifier)
//  }
  
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
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.defaultCellIdentifier, for: indexPath)
    
    guard let completion: MKLocalSearchCompletion = presenter.localSearchCompletion(for: indexPath.row)
    else { return cell }
    
    var configuration: UIListContentConfiguration = .subtitleCell()
    configuration.text = completion.title
    configuration.secondaryText = completion.subtitle
    cell.contentConfiguration = configuration
    
    return cell
  }
}

extension LocalSearchResultTableViewController {
  func inject(presenter: LocalSearchPresenterInput) {
    self.presenter = presenter
  }
}

extension UITableViewCell {
  static let defaultCellIdentifier: String = "defaultCell"
}
