import CoreLocation
@preconcurrency import MapKit

protocol SearchHalfModalPresenterInput {
  var numberOfRoutes: Int { get }
  var numberOfLocations: Int { get }
  
  func route(forRow row: Int) -> RoutingResponse?
  func localSearchCompletion(forRow row: Int) -> MKLocalSearchCompletion?
  @MainActor func didChangeSearchCondition(_ text: String?, tokens: [UISearchToken])
  @MainActor func didSelectRow(at indexPath: IndexPath, in mode: LocalSearchMode)
}

@MainActor
protocol SearchHalfModalPresenterOutput: AnyObject {
  func updateRoutingResults(_ results: [RoutingResponse])
  func updateLocalSearchCompletion(_ results: [MKLocalSearchCompletion]?)
  func insertToken(token: UISearchToken)
  func showLocalSearchFilter()
  func addAnnotation(_ annotation: MKPointAnnotation)
}

final class SearchHalfModalPresenter: SearchHalfModalPresenterInput, @unchecked Sendable {
  private weak var view: SearchHalfModalPresenterOutput!
  private var model: SearchHalfModalModel!
  
  private(set) var routes: [RoutingResponse] = [RoutingResponse]()
  private(set) var localSearchCompletions: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
  private(set) var tokens: [UISearchToken] = [UISearchToken]()
  
  var numberOfRoutes: Int {
    return routes.count
  }
  
  var numberOfLocations: Int {
    return localSearchCompletions.count
  }
  
  init(view: SearchHalfModalPresenterOutput, model: SearchHalfModalModel) {
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
  
  @MainActor func didChangeSearchCondition(_ text: String?, tokens: [UISearchToken]) {
    localSearchCompletions.removeAll()
    
    let filter: MKPointOfInterestFilter = self.model.extractFilter(from: tokens)
    
    Task.detached {
      guard let query: String = text,
            query.isEmpty == true,
            let results: [MKLocalSearchCompletion] = await self.model.searchLocation(from: query, in: filter)
      else { return }
      self.localSearchCompletions.append(contentsOf: results)
      
      Task { @MainActor in
        self.view.updateLocalSearchCompletion(self.localSearchCompletions)
      }
    }
  }
  
  @MainActor func didSelectRow(at indexPath: IndexPath, in mode: LocalSearchMode) {
    switch mode {
    case .routing:
        guard let route: RoutingResponse = route(forRow: indexPath.row) else { return }
    case .location:
        guard let completion: MKLocalSearchCompletion = localSearchCompletion(forRow: indexPath.row) else { return }
        Task.detached {
          guard let annotation: MKPointAnnotation = await self.model.geocodeAddress(from: completion.title)
          else { return }
          
          Task { @MainActor in
            self.view.addAnnotation(annotation)
          }
        }
    case .locationFilter:
        Task.detached {
          let token: UISearchToken = await self.model.createSearchToken(from: indexPath)
          self.tokens.append(token)
          
          Task { @MainActor in
            guard let lastToken: UISearchToken = self.tokens.last else { return }
            self.view.insertToken(token: lastToken)
          }
        }
    }
  }
}
