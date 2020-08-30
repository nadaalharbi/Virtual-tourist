import UIKit
import MapKit
import CoreData

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class TravelLocationsMapView: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var dataController:DataController!
    var pinsArray: [Pin] = []
    // Search
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    // Alert
    var alertController: UIAlertController?
    var alertTimer: Timer?
    var remainingTime = 0
    var baseMessage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupFetchedResults()
        addAnnotations()
        showAlertMsg(title: "Welcome my friend 🤩", message: "With MapN you can search for your place OR press anywhere on the map! 📍", time: 4)
        navigationItem.rightBarButtonItem = editButtonItem
        
        // on long press any where on the map create a pin
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecogniser.delegate = self
        longPressRecogniser.minimumPressDuration = 0.8
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResults()
        addAnnotations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if isEditing {
            showAlertMsg(title: "Delete a pin", message: "Click on pin to delete it 🗑", time: 3)
        }
    }
    
    fileprivate func setupSearchBar() {
        let locationSearchTable = storyboard!.instantiateViewController(identifier: "SearchLocationTable") as! SearchLocationTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as UISearchResultsUpdating
        // setup the search bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for location"
        navigationItem.titleView = resultSearchController?.searchBar
        
        // configures the search bar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation  = true
        definesPresentationContext = true
        locationSearchTable.mapView = self.mapView
        //handle map search delegate
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func setupFetchedResults() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pinsArray = result
            mapView.removeAnnotations(mapView.annotations)
            addAnnotations()
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != UIGestureRecognizer.State.began {
            return
        }
        let location = gestureRecognizer.location(in: mapView)
        let locationCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        let pin = Pin(context: dataController.viewContext)
        pin.lat = locationCoordinate.latitude.magnitude
        pin.lon = locationCoordinate.longitude.magnitude
        pin.createdDate = Date()
        debugPrint("Latitude of the location: \(pin.lat)")
        debugPrint("Longitude of the location: \(pin.lon)")
        do {
            try dataController.viewContext.save()
        }catch{
            debugPrint("Error occured while saving location.")
        }
        pinsArray.append(pin)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        mapView.addAnnotation(annotation)
    }
    
    func addAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
        var annotations = [MKPointAnnotation]()
        
        for pin in pinsArray {
            let lat = Double(pin.lat)
            let long = Double(pin.lon)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
}

// MARK: MapView
extension TravelLocationsMapView: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { debugPrint("no mkpointannotaions"); return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = UIColor.red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        debugPrint("tapped on pin")
        mapView.deselectAnnotation(view.annotation! , animated: true)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PhotosAlbumViewController") as? PhotosAlbumViewController
        
        // pass latitude & longitude to PhotoAlbum coordinate to reuquest the Flickr API
        controller?.locationCoordinate = view.annotation?.coordinate
        debugPrint("ONE: lat: \(String(describing: controller?.locationCoordinate.latitude)), long: \(String(describing: controller?.locationCoordinate.longitude))")
        for pin in pinsArray {
                if isEditing {
                    self.mapView.removeAnnotation(view.annotation!) // remove from map
                    dataController.viewContext.delete(pin)
                    print("viewAnnotation \(pin)")
                    do {
                        try dataController.viewContext.save()
                        debugPrint("pin removed")
                    } catch {
                        debugPrint("error occurred while saving.")
                    }
                    break
                }
            if pin.lat.isEqual(to: view.annotation?.coordinate.latitude.magnitude ?? 90){
                controller?.pin = pin
            }
        }
        if controller?.pin != nil {
        controller?.dataController = dataController
        self.navigationController?.pushViewController(controller!, animated: true)
        }
    }
}

//MARK: Handle MapSearch
extension TravelLocationsMapView: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        selectedPin = placemark
        
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) - \(state)"
        }
        let pin = Pin(context: dataController.viewContext)
        pin.lat = annotation.coordinate.latitude.magnitude
        pin.lon = annotation.coordinate.longitude.magnitude
        pin.createdDate = Date()
        debugPrint("TWO: Latitude of the location: \(pin.lat)")
        debugPrint("TWO: Longitude of the location: \(pin.lon)")
        do {
            try dataController.viewContext.save()
        }catch{
            debugPrint("Error occured while saving location.")
        }
        pinsArray.append(pin) // add a searched pin to array
        mapView.addAnnotation(annotation)// add a pin to the map
        // Zoom in
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: Handle AlertController
extension TravelLocationsMapView {
    func showAlertMsg(title: String, message: String, time: Int) {
        guard (self.alertController == nil) else {
            return
        }
        self.baseMessage = message
        self.remainingTime = time
        self.alertController = UIAlertController(title: title, message: self.alertMessage(), preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .cancel) { (action) in
            print("AlertMsg cancelled")
            self.alertController=nil;
            self.alertTimer?.invalidate()
            self.alertTimer=nil
        }
        self.alertController!.addAction(okayAction)
        self.alertTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timer), userInfo: nil, repeats: true)
        self.present(self.alertController!, animated: true, completion: nil)
    }
    
    @objc func timer() {
        self.remainingTime -= 1
        if (self.remainingTime < 0) {
            self.alertTimer?.invalidate()
            self.alertTimer = nil
            self.alertController!.dismiss(animated: true, completion: {
                self.alertController = nil
            })
        } else {
            self.alertController!.message = self.alertMessage()
        }
    }
    
    func alertMessage() -> String {
        var message = ""
        if let baseMessage = self.baseMessage {
            message = baseMessage
        }
        return message
    }
}
