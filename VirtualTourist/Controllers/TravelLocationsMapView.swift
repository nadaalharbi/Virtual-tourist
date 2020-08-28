import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var dataController:DataController!
    var pinsArray: [Pin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResults()
        addAnnotations()
        
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
        debugPrint("longitude of the location: \(pin.lon)")
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
        for pin in pinsArray {
            if pin.lat.isEqual(to: view.annotation?.coordinate.latitude.magnitude ?? 90){
                controller?.pin = pin
            }
        }
        controller?.dataController = dataController
        self.navigationController?.pushViewController(controller!, animated: true)
    }
}
