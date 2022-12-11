import OrderedCollections
import MapKit

enum FilteringCategories: CaseIterable {
  case airport
  case amusementPark
  case aquarium
  case atm
  case bakery
  case bank
  case beach
  case brewery
  case cafe
  case campground
  case carRental
  case evCharger
  case fireStation
  case fitnessCenter
  case foodMarket
  case gasStation
  case hospital
  case hotel
  case laundry
  case library
  case marina
  case movieTheater
  case museum
  case nationalPark
  case nightlife
  case park
  case parking
  case pharmacy
  case police
  case postOffice
  case publicTransport
  case restaurant
  case restroom
  case school
  case stadium
  case store
  case theater
  case university
  case winery
  case zoo
  
  var name: String {
    switch self {
      case .airport:
        return NSLocalizedString("airport", comment: "")
      case .amusementPark:
        return NSLocalizedString("amusementPark", comment: "")
      case .aquarium:
        return NSLocalizedString("aquarium", comment: "")
      case .atm:
        return NSLocalizedString("atm", comment: "")
      case .bakery:
        return NSLocalizedString("bakery", comment: "")
      case .bank:
        return NSLocalizedString("bank", comment: "")
      case .beach:
        return NSLocalizedString("beach", comment: "")
      case .brewery:
        return NSLocalizedString("brewery", comment: "")
      case .cafe:
        return NSLocalizedString("cafe", comment: "")
      case .campground:
        return NSLocalizedString("campground", comment: "")
      case .carRental:
        return NSLocalizedString("carRental", comment: "")
      case .evCharger:
        return NSLocalizedString("evCharger", comment: "")
      case .fireStation:
        return NSLocalizedString("fireStation", comment: "")
      case .fitnessCenter:
        return NSLocalizedString("fitnessCenter", comment: "")
      case .foodMarket:
        return NSLocalizedString("foodMarket", comment: "")
      case .gasStation:
        return NSLocalizedString("gasStation", comment: "")
      case .hospital:
        return NSLocalizedString("hospital", comment: "")
      case .hotel:
        return NSLocalizedString("hotel", comment: "")
      case .laundry:
        return NSLocalizedString("laundry", comment: "")
      case .library:
        return NSLocalizedString("library", comment: "")
      case .marina:
        return NSLocalizedString("marina", comment: "")
      case .movieTheater:
        return NSLocalizedString("movieTheater", comment: "")
      case .museum:
        return NSLocalizedString("museum", comment: "")
      case .nationalPark:
        return NSLocalizedString("nationalPark", comment: "")
      case .nightlife:
        return NSLocalizedString("nightlife", comment: "")
      case .park:
        return NSLocalizedString("park", comment: "")
      case .parking:
        return NSLocalizedString("parking", comment: "")
      case .pharmacy:
        return NSLocalizedString("pharmacy", comment: "")
      case .police:
        return NSLocalizedString("police", comment: "")
      case .postOffice:
        return NSLocalizedString("postOffice", comment: "")
      case .publicTransport:
        return NSLocalizedString("publicTransport", comment: "")
      case .restaurant:
        return NSLocalizedString("restaurant", comment: "")
      case .restroom:
        return NSLocalizedString("restroom", comment: "")
      case .school:
        return NSLocalizedString("school", comment: "")
      case .stadium:
        return NSLocalizedString("stadium", comment: "")
      case .store:
        return NSLocalizedString("store", comment: "")
      case .theater:
        return NSLocalizedString("theater", comment: "")
      case .university:
        return NSLocalizedString("university", comment: "")
      case .winery:
        return NSLocalizedString("winery", comment: "")
      case .zoo:
        return NSLocalizedString("zoo", comment: "")
    }
  }
  
  var category: MKPointOfInterestCategory {
    switch self {
      case .airport: return .airport
      case .amusementPark: return .amusementPark
      case .aquarium: return .aquarium
      case .atm: return .atm
      case .bakery: return .bakery
      case .bank: return .bank
      case .beach: return .beach
      case .brewery: return .brewery
      case .cafe: return .cafe
      case .campground: return .campground
      case .carRental: return .carRental
      case .evCharger: return .evCharger
      case .fireStation: return .fireStation
      case .fitnessCenter: return .fitnessCenter
      case .foodMarket: return .foodMarket
      case .gasStation: return .gasStation
      case .hospital: return .hospital
      case .hotel: return .hotel
      case .laundry: return .laundry
      case .library: return .library
      case .marina: return .marina
      case .movieTheater: return .movieTheater
      case .museum: return .museum
      case .nationalPark: return .nationalPark
      case .nightlife: return .nightlife
      case .park: return .park
      case .parking: return .parking
      case .pharmacy: return .pharmacy
      case .police: return .police
      case .postOffice: return .postOffice
      case .publicTransport: return .publicTransport
      case .restaurant: return .restaurant
      case .restroom: return .restroom
      case .school: return .school
      case .stadium: return .stadium
      case .store: return .store
      case .theater: return .theater
      case .university: return .university
      case .winery: return .winery
      case .zoo: return .zoo
    }
  }
  
  var image: UIImage? {
    switch self {
      case .airport:
        return UIImage(systemName: "airplane")
      case .amusementPark:
        return UIImage(systemName: "figure.mixed.cardio")
      case .aquarium:
        return UIImage(systemName: "fish")
      case .atm:
        return UIImage(named: "atm")
      case .bakery:
        return UIImage(named: "bakery")
      case .bank:
        return UIImage(named: "bank")
      case .beach:
        return UIImage(systemName: "water.waves")
      case .brewery, .winery:
        return UIImage(systemName: "wineglass")
      case .cafe:
        return UIImage(systemName: "cup.and.saucer")
      case .campground:
        return UIImage(named: "campground")
      case .carRental:
        return UIImage(systemName: "car.2")
      case .evCharger:
        return UIImage(systemName: "bolt.car")
      case .fireStation:
        return UIImage(systemName: "fireplace")
      case .fitnessCenter:
        return UIImage(systemName: "figure.mind.and.body")
      case .foodMarket:
        return UIImage(systemName: "carrot")
      case .gasStation:
        return UIImage(systemName: "fuelpump")
      case .hospital:
        return UIImage(systemName: "stethoscope")
      case .hotel:
        return UIImage(named: "hotel")
      case .laundry:
        return UIImage(named: "laundry")
      case .library:
        return UIImage(systemName: "books.vertical")
      case .marina:
        return UIImage(systemName: "sailboat")
      case .movieTheater:
        return UIImage(named: "movieTheater")
      case .museum:
        return UIImage(named: "museum")
      case .nationalPark:
        return UIImage(named: "bird")
      case .nightlife:
        return UIImage(systemName: "moon")
      case .park:
        return UIImage(systemName: "figure.and.child.holdinghands")
      case .parking:
        return UIImage(systemName: "parkingsign")
      case .pharmacy:
        return UIImage(named: "pharmacy")
      case .police:
        return UIImage(named: "police")
      case .postOffice:
        return UIImage(systemName: "envelope")
      case .publicTransport:
        return UIImage(systemName: "bus")
      case .restaurant:
        return UIImage(systemName: "fork.knife")
      case .restroom:
        return UIImage(systemName: "toilet")
      case .school, .university:
        return UIImage(systemName: "school")
      case .stadium:
        return UIImage(systemName: "sportscourt")
      case .store:
        return UIImage(systemName: "cart")
      case .theater:
        return UIImage(named: "theater")
      case .zoo:
        return UIImage(named: "zoo")
    }
  }
}
