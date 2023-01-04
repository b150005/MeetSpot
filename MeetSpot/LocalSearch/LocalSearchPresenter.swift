import CoreLocation
@preconcurrency import MapKit

// TODO: - Presenterの大体的修正

@MainActor
protocol LocalSearchPresenterInput {
  func didTapFilteringCategory(_ category: FilteringCategories)
  func didTapToken(at tokenIndex: Int)
  func didChangeSearchCondition(_ text: String?, tokens: [UISearchToken])
  func localSearchCompletion(for row: Int) -> MKLocalSearchCompletion?
  func route(forRow row: Int) -> RoutingResponse?
}

@MainActor
protocol LocalSearchPresenterOutput: AnyObject {
  func insertToken(token: UISearchToken)
  func deleteToken(at tokenIndex: Int)
  func updateLocalSearchCompletion()
//  func updateRoutingResults(_ results: [RoutingResponse])
//  func showLocalSearchFilter()
//  func addAnnotation(_ annotation: MKPointAnnotation)
}

final class LocalSearchPresenter: LocalSearchPresenterInput, @unchecked Sendable {
  private weak var view: LocalSearchPresenterOutput!
  private var model: LocalSearchModel!
  
  private(set) var routes: [RoutingResponse] = [RoutingResponse]()
  private(set) var localSearchCompletions: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
  
  var numberOfRoutes: Int {
    return routes.count
  }
  
  var numberOfLocations: Int {
    return localSearchCompletions.count
  }
  
  init(view: LocalSearchPresenterOutput, model: LocalSearchModel) {
    self.view = view
    self.model = model
  }
  
  func didTapFilteringCategory(_ category: FilteringCategories) {
    let token: UISearchToken = UISearchToken(icon: category.image, text: category.name)
    token.representedObject = category.category
    view.insertToken(token: token)
  }
  
  func didTapToken(at tokenIndex: Int) {
    view.deleteToken(at: tokenIndex)
  }
  
  func route(forRow row: Int) -> RoutingResponse? {
    guard row < routes.count else { return nil }
    return routes[row]
  }
  
  func localSearchCompletion(for row: Int) -> MKLocalSearchCompletion? {
    guard row < localSearchCompletions.count else { return nil }
    return localSearchCompletions[row]
  }
  
  func didChangeSearchCondition(_ text: String?, tokens: [UISearchToken]) {
    guard let keyword = text, keyword.isEmpty
    else {
      localSearchCompletions.removeAll()
      view.updateLocalSearchCompletion()
      return
    }
    
    let filter: MKPointOfInterestFilter = model.extractFilter(from: tokens)
    Task.detached {
      let completions: [MKLocalSearchCompletion] = await self.model.searchLocation(from: keyword, in: filter)
      Task { @MainActor in
        self.localSearchCompletions = completions
        self.view.updateLocalSearchCompletion()
      }
    }
  }
}
