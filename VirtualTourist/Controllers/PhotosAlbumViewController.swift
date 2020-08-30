import UIKit
import MapKit
import CoreData
import Kingfisher

class PhotosAlbumViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollection: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingStatusLabel: UILabel!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var pin: Pin!
    var photos: [Photo]!
    var locationCoordinate: CLLocationCoordinate2D!
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupSmallMap()
        setupFetchedResultsController()
        updateLoadingStatus("")
        if (fetchedResultsController.sections?[0].numberOfObjects ?? 0 == 0) {
            loadPhotos()
        }
        if let photos = pin.photos, photos.count == 0 {
            loadPhotos()
        }
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setupFetchedResultsController()
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupFetchedResultsController()
        self.collectionView.reloadData()
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: dataController.viewContext,
            sectionNameKeyPath: nil, cacheName: "photos")
        fetchedResultsController.delegate = self
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            photos = result
        }
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        self.collectionView.reloadData()
    }
    
    fileprivate func setupSmallMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        mapView.addAnnotation(annotation)
        // zoom on the pressed pin
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: locationCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
        self.newCollection.isUserInteractionEnabled = false
        if let photos = fetchedResultsController.fetchedObjects {
            for photo in photos {
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                    debugPrint("deleted then saved")
                } catch {
                    debugPrint("Error occured while saving data.")
                }
            }
        }
        photos.removeAll()
        loadPhotos()
        self.performUIUpdatesOnMain {
            self.collectionView.reloadData()
        }
        self.newCollection.isUserInteractionEnabled = true
    }
    
    func loadPhotos(){
        self.activityIndicator.startAnimating()
        self.updateLoadingStatus("Loading photos ...")
        FlickrAPI.getRequestLocationPhotos(lat: locationCoordinate.latitude, lon: locationCoordinate.longitude) {
            (error, photoUrls) in
            if error != nil {
                debugPrint("Error occured while requesting")
                self.activityIndicator.stopAnimating()
                self.updateLoadingStatus("Error occured while loading")
            }
            for photoUrl in photoUrls! {
                self.activityIndicator.stopAnimating()
                self.updateLoadingStatus("")
                
                let photo = Photo(context: self.dataController.viewContext)
                photo.url = photoUrl
                photo.pin = self.pin
                photo.createdDate = Date()
                try? self.dataController.viewContext.save()
            }
        }
        //DispatchQueue.main.async {
            self.collectionView.reloadData()
        //}
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    func updateLoadingStatus(_ text: String){
        self.performUIUpdatesOnMain {
            self.loadingStatusLabel.text = text
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            debugPrint("Move an item. We don't expect to see this in this app.")
            break
        @unknown default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }, completion: nil)
    }
}
