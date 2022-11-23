import UIKit
import MapKit

@MainActor
final class SearchHalfModalViewController: UIViewController {
  // MARK: - Properties
  private let localSearchTableViewController: LocalSearchTableViewController = {
    let controller: LocalSearchTableViewController = LocalSearchTableViewController()
    return controller
  }()
  
  private var localSearchController: UISearchController!
  
  private var presenter: SearchHalfModalPresenterInput!
  
  // MARK: - Overridden Methods
  
  override func loadView() {
    localSearchController = UISearchController(searchResultsController: localSearchTableViewController)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func updateViewConstraints() {
    
  }
}

extension SearchHalfModalViewController {
  func inject(presenter: SearchHalfModalPresenterInput) {
    self.presenter = presenter
  }
}

extension SearchHalfModalViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if let text: String = searchBar.text, text.isEmpty == true {
      localSearchTableViewController.searchMode = .locationFilter
    }
    else {
      localSearchTableViewController.searchMode = .location
    }
  }
  
  func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    Task {
      do {
        try await Task.sleep(nanoseconds: 100_000_000)
        if let keyword: String = searchBar.text, keyword.isEmpty == false {
          self.presenter.didChangeSearchCondition(keyword, tokens: searchBar.searchTextField.tokens)
        }
      }
      catch {
        return
      }
    }
    
    return false
  }
}

extension SearchHalfModalViewController: SearchHalfModalPresenterOutput {
  func updateRoutingResults(_ results: [RoutingResponse]) {
    localSearchTableViewController.searchMode = .routing
  }
  
  func updateLocalSearchCompletion(_ results: [MKLocalSearchCompletion]?) {
    guard let _ = results else { return }
    localSearchTableViewController.searchMode = .location
  }
  
  func insertToken(token: UISearchToken) {
    let index: Int = localSearchController.searchBar.searchTextField.tokens.count
    localSearchController.searchBar.searchTextField.insertToken(token, at: index)
  }
  
  func showLocalSearchFilter() {
    localSearchTableViewController.searchMode = .locationFilter
  }
  
  func addAnnotation(_ annotation: MKPointAnnotation) {
    guard let navigationController: UINavigationController = self.navigationController,
          let presentingVC: RoutingMapViewController = navigationController.presentingViewController as? RoutingMapViewController
    else { return }
  }
}
