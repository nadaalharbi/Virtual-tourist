import UIKit
import Kingfisher

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        imageView.image = nil
//        imageView.kf.indicatorType = .activity
//    }
}
