import UIKit
import Kingfisher

private let reuseIdentifier = "Cell"

extension PhotosAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.activityIndicator.startAnimating()
        
        let photo = fetchedResultsController.object(at: indexPath)
        if let image = photo.image {
            cell.imageView.image = UIImage(data: image)
            cell.imageView.contentMode = UIView.ContentMode.center
        } else if let photoUrl = photo.url {
            guard let url = URL(string: photoUrl) else {
                return cell
            }
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder"), options: nil, progressBlock: nil) { (image, error, cacheType, url) in
                if ((error) != nil) {
                    debugPrint("error setting image")
                } else {
                    photo.image = image?.pngData()// store in the DB
                    try? self.dataController.viewContext.save() // save Context
                    debugPrint("done setting image")
                }
            }
        }
        cell.activityIndicator.stopAnimating()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        debugPrint("clicked on cell")
        let photo = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photo)
        do {
            try dataController.viewContext.save()
        } catch {
            debugPrint("Error occurred while saving")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath)-> CGSize {
        let bounds = collectionView.bounds
        return CGSize(width: (bounds.width/2)-4, height: bounds.height/5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2).right
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
