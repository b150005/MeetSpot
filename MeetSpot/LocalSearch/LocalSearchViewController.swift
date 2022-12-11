import UIKit

final class LocalSearchViewController: UIViewController {
  private var presenter: LocalSearchPresenterInput!
  
  private var localSearchController: UISearchController!
  private let localSearchResultTableViewController: LocalSearchResultTableViewController = LocalSearchResultTableViewController()
  
  private let filterLabel: UILabel = UILabel()
  private let filterScrollView: UIScrollView = UIScrollView()
  
  override func loadView() {
    super.loadView()
    
    configureLocalSearchController()
    configureFilterLabel()
    configureFilterScrollView()
  }
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
    
    NSLayoutConstraint.activate([
      localSearchController.searchBar.widthAnchor.constraint(equalTo: view.widthAnchor),
      localSearchController.searchBar.heightAnchor.constraint(equalToConstant: view.frame.height / 10),
      localSearchController.searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      localSearchController.searchBar.topAnchor.constraint(equalTo: view.topAnchor)
    ])
    
    NSLayoutConstraint.activate([
      filterLabel.topAnchor.constraint(equalTo: localSearchController.searchBar.bottomAnchor, constant: Constants.margin),
      filterLabel.leftAnchor.constraint(equalTo: view.leftAnchor)
    ])
    
    NSLayoutConstraint.activate([
      filterScrollView.topAnchor.constraint(equalTo: <#T##NSLayoutAnchor<NSLayoutYAxisAnchor>#>, constant: <#T##CGFloat#>)
    ])
    
    for view in filterScrollView.subviews {
      guard let toggle: UIButton = view as? UIButton else { return }
      switch toggle {
        case filterScrollView.subviews.first!:
          NSLayoutConstraint.activate([
            toggle.leftAnchor.constraint(equalTo: filterScrollView.leftAnchor, constant: Constants.margin),
            toggle.leftAnchor.constraint(equalTo: <#T##NSLayoutAnchor<NSLayoutXAxisAnchor>#>, constant: <#T##CGFloat#>)
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
    localSearchController.searchBar.setNeedsUpdateConstraints()
    navigationItem.searchController = localSearchController
  }
  
  private func configureFilterLabel() {
    
    
    filterLabel.translatesAutoresizingMaskIntoConstraints = false
    filterLabel.setNeedsUpdateConstraints()
    view.addSubview(filterLabel)
  }
  
  private func configureFilterScrollView() {
    filterScrollView.translatesAutoresizingMaskIntoConstraints = false
    filterScrollView.setNeedsUpdateConstraints()
    view.addSubview(filterScrollView)
    
    for category: FilteringCategories in FilteringCategories.allCases {
      let toggle: UIButton = UIButton(type: .roundedRect)
      var configuration: UIButton.Configuration = .gray()
      configuration.title = category.name
      configuration.image = category.image
      configuration.cornerStyle = .dynamic
      toggle.configuration = configuration
      toggle.sizeToFit()
      
      toggle.translatesAutoresizingMaskIntoConstraints = false
      toggle.setNeedsUpdateConstraints()
      filterScrollView.addSubview(toggle)
    }
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
      if let keyword: String = searchBar.text, !keyword.isEmpty {
        presenter.didChangeSearchCondition(keyword, tokens: <#T##[UISearchToken]#>)
      }
      else {
        
      }
    }
    
    return true
  }
}

extension LocalSearchViewController: LocalSearchPresenterOutput {
  
}
