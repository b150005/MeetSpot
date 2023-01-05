import UIKit
import MapKit

final class LocalSearchViewController: UIViewController {
  private var presenter: LocalSearchPresenterInput!
  
  private let localSearchBar: UISearchBar = UISearchBar()
  private let localSearchResultTableViewController: LocalSearchResultTableViewController = LocalSearchResultTableViewController()
  
  private let filterLabel: UILabel = UILabel()
  private let filterScrollView: UIScrollView = UIScrollView()
  
  override func loadView() {
    super.loadView()
    
    view.backgroundColor = .white
    configureLocalSearchResultTableViewController()
    configureLocalSearchBar()
    configureFilterLabel()
    configureFilterScrollView()
    
    localSearchBar.setNeedsUpdateConstraints()
    filterLabel.setNeedsUpdateConstraints()
    filterScrollView.setNeedsUpdateConstraints()
  }
  
  override func updateViewConstraints() {
    super.updateViewConstraints()
    
    NSLayoutConstraint.activate([
      localSearchBar.widthAnchor.constraint(equalTo: view.widthAnchor),
      localSearchBar.heightAnchor.constraint(equalToConstant: 50),
      localSearchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.margin),
      localSearchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
    
    NSLayoutConstraint.activate([
      filterLabel.widthAnchor.constraint(equalTo: localSearchBar.widthAnchor),
      filterLabel.heightAnchor.constraint(equalToConstant: Constants.margin * 3),
      filterLabel.topAnchor.constraint(equalTo: localSearchBar.bottomAnchor, constant: Constants.margin),
      filterLabel.leftAnchor.constraint(equalTo: view.leftAnchor)
    ])
    
    NSLayoutConstraint.activate([
      filterScrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 10),
      filterScrollView.heightAnchor.constraint(equalToConstant: Constants.margin * 11),
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
  
  private func configureLocalSearchBar() {
    localSearchBar.delegate = self
    localSearchBar.placeholder = NSLocalizedString("searchPlaceholder", comment: "")
    definesPresentationContext = true
    
    localSearchBar.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(localSearchBar)
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
    filterScrollView.isScrollEnabled = true
    filterScrollView.showsVerticalScrollIndicator = false
    filterScrollView.showsHorizontalScrollIndicator = true
    filterScrollView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(filterScrollView)
    
    for category: FilteringCategories in FilteringCategories.allCases {
      let toggle: UIButton = UIButton(type: .system)
      var configuration: UIButton.Configuration = .tinted()
      configuration.title = category.name
      configuration.image = category.image?.scalePreservingAspectRatio().withRenderingMode(.alwaysTemplate)
      configuration.imagePadding = Constants.margin / 2
      toggle.configuration = configuration
      toggle.translatesAutoresizingMaskIntoConstraints = false
//      toggle.setNeedsUpdateConstraints()
      
      toggle.sizeToFit()
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
    localSearchBar.searchTextField.insertToken(token, at: 0)
  }
  
  func deleteToken(at tokenIndex: Int) {
    localSearchBar.searchTextField.removeToken(at: tokenIndex)
  }
  
  func updateLocalSearchCompletion() {
    localSearchResultTableViewController.tableView.reloadData()
  }
}

extension LocalSearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //
  }
  
  func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    Task {
      try await Task.sleep(for: .milliseconds(100))
      presenter.didChangeSearchCondition(searchBar.text, tokens: searchBar.searchTextField.tokens)
    }
    
    return true
  }
}
