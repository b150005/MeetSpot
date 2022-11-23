import UIKit
import MapKit

enum LocalSearchMode {
  case routing
  case location
  case locationFilter
}

final class LocalSearchTableViewController: UITableViewController {
  private var presenter: SearchHalfModalPresenterInput!
  
  var searchMode: LocalSearchMode = .routing {
    didSet {
      if oldValue != searchMode {
        tableView.reloadData()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - UITableViewDataSource
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch searchMode {
      case .routing:
        return NSLocalizedString("routingSectionTitle", comment: "")
      case .location:
        return nil
      case .locationFilter:
        return NSLocalizedString("locationFilterSectionTitle", comment: "")
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch searchMode {
      case .routing:
        return presenter.numberOfRoutes
      case .location:
        return presenter.numberOfLocations
      case .locationFilter:
        return FilteringCategories.categories.count
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell = UITableViewCell(style: .subtitle,
                                                reuseIdentifier: UITableViewCell.localSearchCellIdentifier)
    var content: UIListContentConfiguration = .subtitleCell()
    
    switch searchMode {
      case .routing:
        print("placeholder")
      case .location:
        guard let localSearchResult: MKLocalSearchCompletion = presenter.localSearchCompletion(forRow: indexPath.row)
        else { return cell }
        
        content.text = localSearchResult.title
        content.secondaryText = localSearchResult.subtitle
      case .locationFilter:
        content.text = FilteringCategories.categories.elements[indexPath.row].key
    }
    
    cell.contentConfiguration = content
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    
  }
}

extension LocalSearchTableViewController {
  func inject(presenter: SearchHalfModalPresenterInput) {
    self.presenter = presenter
  }
}
