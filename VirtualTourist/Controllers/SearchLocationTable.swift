import UIKit
import MapKit

class SearchLocationTable: UITableViewController {
    
    var mapItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate: HandleMapSearch? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        let selectedItem = mapItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseLocationInfo(selectedItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = mapItems[indexPath.row].placemark
        self.handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchLocationTable: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = self.mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.mapItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    func parseLocationInfo(_ selectedItem:MKPlacemark) -> String {
        // put a - between Number and Place
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " - " : ""
        // put a comma between street and city OR state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC" to be -> "Washington DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : " "
        let address = String(format:"%@%@%@%@%@%@%@",
                             // for street number
            selectedItem.subThoroughfare ?? "",firstSpace,
            // for treet name
            selectedItem.thoroughfare ?? "", comma,
            // for city
            selectedItem.locality ?? "", secondSpace,
            // for state
            selectedItem.administrativeArea ?? ""
        )
        return address
    }
}
