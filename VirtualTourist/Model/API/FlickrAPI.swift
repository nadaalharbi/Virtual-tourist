/*
 My Flickr Key:
 9354c160517ffad3d8605f61bbe1ea66
 */
import Foundation
import Alamofire
import SwiftyJSON

class FlickrAPI {
    
    struct FlickrRequestKeys {
        static let METHOD = "flickr.photos.search"
        static let API_KEY = "9354c160517ffad3d8605f61bbe1ea66"
        static let API_SECRET = "5d2e8b55cbd9637c"
        static let PER_PAGE = 20
    }
    
    static func getRequestLocationPhotos(lat: Double, lon: Double, tags:String = "", completion: @escaping (_ error: Error?, [String]?) -> Void) {
        let url = "https://api.flickr.com/services/rest/?&method=\(FlickrAPI.FlickrRequestKeys.METHOD)&api_key=\(FlickrAPI.FlickrRequestKeys.API_KEY)&lat=\(lat)&lon=\(lon)&format=json&nojsoncallback=1&page=\((1...10).randomElement() ?? 1)&per_page=\(FlickrAPI.FlickrRequestKeys.PER_PAGE)&extras=url_m"
        
        let request = AF.request(url)
        request.responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var photoUrls:[String] = []
                if let photos = json["photos"]["photo"].array {
                    for photo in photos{
                        let url = "https://farm\(photo["farm"].stringValue).staticflickr.com/\(photo["server"].stringValue)/\(photo["id"])_\(photo["secret"]).jpg"
                        photoUrls.append(url)
                    }
                }
                completion(nil, photoUrls)
                print("JSON Data: \(json)")
                break
            case .failure(let error):
                print("failed requesting \(error.localizedDescription)")
                completion(error, nil)
                break
            }
        }
    }
}
