import CoreLocation
@preconcurrency import MapKit

protocol LocalSearchPresenterInput {
  var numberOfRoutes: Int { get }
  var numberOfLocations: Int { get }
  
  func route(forRow row: Int) -> RoutingResponse?
  func localSearchCompletion(forRow row: Int) -> MKLocalSearchCompletion?
  @MainActor func didChangeSearchCondition(_ text: String, tokens: [UISearchToken])
}

@MainActor
protocol LocalSearchPresenterOutput: AnyObject {
  func updateRoutingResults(_ results: [RoutingResponse])
  func updateLocalSearchCompletion(_ results: [MKLocalSearchCompletion]?)
  func insertToken(token: UISearchToken)
  func showLocalSearchFilter()
  func addAnnotation(_ annotation: MKPointAnnotation)
}

final class LocalSearchPresenter: LocalSearchPresenterInput, @unchecked Sendable {
  private weak var view: LocalSearchPresenterOutput!
  private var model: LocalSearchModel!
  
  private(set) var routes: [RoutingResponse] = [RoutingResponse]()
  private(set) var localSearchCompletions: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
  private(set) var tokens: [UISearchToken] = [UISearchToken]()
  
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
  
  func route(forRow row: Int) -> RoutingResponse? {
    guard row < routes.count else { return nil }
    return routes[row]
  }
  
  func localSearchCompletion(forRow row: Int) -> MKLocalSearchCompletion? {
    guard row < localSearchCompletions.count else { return nil }
    return localSearchCompletions[row]
  }
  
  @MainActor func didChangeSearchCondition(_ text: String, tokens: [UISearchToken]) {
    localSearchCompletions.removeAll()
    
    let filter: MKPointOfInterestFilter = self.model.extractFilter(from: tokens)
    
    Task.detached {
      guard text.isEmpty == true,
            let results: [MKLocalSearchCompletion] = await self.model.searchLocation(from: text, in: filter)
      else { return }
      self.localSearchCompletions.append(contentsOf: results)
      
      Task { @MainActor in
        self.view.updateLocalSearchCompletion(self.localSearchCompletions)
      }
    }
  }
}
