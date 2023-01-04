import UIKit
import MapKit

final class LocalSearchViewController: UIViewController {
  private var presenter: LocalSearchPresenterInput!
  
  private var localSearchController: UISearchController!
  private let localSearchResultTableViewController: LocalSearchResultTableViewController = LocalSearchResultTableViewController()
  
  private let filterLabel: UILabel = UILabel()
  private let filterScrollView: UIScrollView = UIScrollView()
  
  override func loadView() {
    super.loadView()
    
    view.backgroundColor = .white
    configureLocalSearchResultTableViewController()
    configureLocalSearchController()
    configureFilterLabel()
    configureFilterScrollView()
    
    localSearchController.searchBar.setNeedsUpdateConstraints()
    filterLabel.setNeedsUpdateConstraints()
    filterScrollView.setNeedsUpdateConstraints()
  }
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
    
    print("Hello!!")
    
    let parentView: UIView = navigationItem.searchController!.searchBar
    NSLayoutConstraint.activate([
      localSearchController.searchBar.widthAnchor.constraint(equalTo: parentView.widthAnchor),
      localSearchController.searchBar.heightAnchor.constraint(equalToConstant: parentView.frame.height / 10),
      localSearchController.searchBar.topAnchor.constraint(equalTo: parentView.topAnchor),
      localSearchController.searchBar.centerXAnchor.constraint(equalTo: parentView.centerXAnchor)
    ])
    
    NSLayoutConstraint.activate([
      filterLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
      filterLabel.heightAnchor.constraint(equalToConstant: Constants.margin * 3),
      filterLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.margin),
      filterLabel.leftAnchor.constraint(equalTo: view.leftAnchor)
    ])
    
    NSLayoutConstraint.activate([
      filterScrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 10),
      filterScrollView.heightAnchor.constraint(equalToConstant: Constants.margin * 10),
      filterScrollView.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: Constants.margin),
      filterScrollView.leftAnchor.constraint(equalTo: view.leftAnchor)
    ])
    
    var standardView: UIView
    let countInRow: Int = Int(ceil(Double(filterScrollView.subviews.count) / 3))
    for viewIndex in 0 ..< filterScrollView.subviews.count {
      guard let toggle: UIButton = filterScrollView.subviews[viewIndex] as? UIButton else { return }
      switch viewIndex {
        case 0:
          NSLayoutConstraint.activate([
            toggle.topAnchor.constraint(equalTo: filterScrollView.topAnchor, constant: Constants.margin),
            toggle.leftAnchor.constraint(equalTo: filterScrollView.leftAnchor, constant: Constants.margin)
          ])
        case let firstIndexInRow where firstIndexInRow % countInRow == 0:
          standardView = filterScrollView.subviews[firstIndexInRow - countInRow]
          NSLayoutConstraint.activate([
            toggle.topAnchor.constraint(equalTo: standardView.bottomAnchor, constant: Constants.margin),
            toggle.leftAnchor.constraint(equalTo: filterScrollView.leftAnchor, constant: Constants.margin)
          ])
        default:
          standardView = filterScrollView.subviews[viewIndex - 1]
          NSLayoutConstraint.activate([
            toggle.topAnchor.constraint(equalTo: standardView.topAnchor),
            toggle.leftAnchor.constraint(equalTo: standardView.rightAnchor, constant: Constants.margin)
          ])
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension LocalSearchViewController {
  func inject(presenter: LocalSearchPresenterInput) {
    self.presenter = presenter
  }
  
  private func configureLocalSearchController() {
    localSearchController = UISearchController(searchResultsController: localSearchResultTableViewController)
    localSearchController.searchResultsUpdater = self
    localSearchController.searchBar.delegate = self
    localSearchController.hidesNavigationBarDuringPresentation = true
    localSearchController.obscuresBackgroundDuringPresentation = false
    
    localSearchController.searchBar.placeholder = NSLocalizedString("", comment: "")
    definesPresentationContext = true
    
    localSearchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
    navigationItem.searchController = localSearchController
  }
  
  private func configureLocalSearchResultTableViewController() {
    localSearchResultTableViewController.inject(presenter: presenter)
  }
  
  private func configureFilterLabel() {
    filterLabel.text = NSLocalizedString("filterLabel", comment: "")
    
    filterLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(filterLabel)
  }
  
  private func configureFilterScrollView() {
    filterScrollView.backgroundColor = .green
    filterScrollView.isDirectionalLockEnabled = true
    filterScrollView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(filterScrollView)
    
    for category: FilteringCategories in FilteringCategories.allCases {
      let toggle: UIButton = UIButton(type: .roundedRect)
      var configuration: UIButton.Configuration = .gray()
      configuration.title = category.name
      configuration.image = category.image
      configuration.cornerStyle = .dynamic
      toggle.configuration = configuration
      toggle.clipsToBounds = true
      toggle.sizeToFit()
      toggle.frame.size = CGSize(width: toggle.frame.width + Constants.margin * 2, height: toggle.frame.height)
      toggle.translatesAutoresizingMaskIntoConstraints = false
//      toggle.setNeedsUpdateConstraints()
      
      toggle.addAction(UIAction() { [weak self] _ in
        guard let self else { return }
        self.presenter.didTapFilteringCategory(category)
      }, for: .primaryActionTriggered)
      
      filterScrollView.addSubview(toggle)
    }
  }
}

extension LocalSearchViewController: LocalSearchPresenterOutput {
  func insertToken(token: UISearchToken) {
    localSearchController.searchBar.searchTextField.insertToken(token, at: 0)
  }
  
  func deleteToken(at tokenIndex: Int) {
    localSearchController.searchBar.searchTextField.removeToken(at: tokenIndex)
  }
  
  func updateLocalSearchCompletion() {
    localSearchResultTableViewController.tableView.reloadData()
  }
}

extension LocalSearchViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    //
  }
}

extension LocalSearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //
  }
  
  func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    localSearchController.showsSearchResultsController = true
    
    Task {
      try await Task.sleep(for: .milliseconds(100))
      presenter.didChangeSearchCondition(searchBar.text, tokens: searchBar.searchTextField.tokens)
    }
    
    return true
  }
}

//extension LocalSearchViewController: UIScrollViewDelegate {
//  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//    filterScrollView.startPoi
//  }
//}
