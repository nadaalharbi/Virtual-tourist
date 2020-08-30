# Virtual-tourist
Virtual Tourist or MapN in an app that shows a map with ability to serach for a place or press anywhere on the map to add the pin and enjoy watching amazing photos of the tapped location - pin!
You can also delete a pin from your map.

This project is build for my iOS Nanodegree program - Udacity

## Screenshot 
<img src="https://github.com/nadaalharbi/Virtual-tourist/blob/master/images/splashView.png" width="250" height="450">              <img src="https://github.com/nadaalharbi/Virtual-tourist/blob/master/images/WelcomePage.png" width="250" height="450">               <img src="https://github.com/nadaalharbi/Virtual-tourist/blob/master/images/removePin.png" width="250" height="450">              <img src="https://github.com/nadaalharbi/Virtual-tourist/blob/master/images/mapPage.png" width="250" height="450">              <img src="https://github.com/nadaalharbi/Virtual-tourist/blob/master/images/photoAlbum2.png" width="250" height="450">
## Build
### Requirements
* Xcode 11.4
* Swift 5.1

### Steps to build
1. Clone repo 
```
git clone https://github.com/nadaalharbi/Virtual-tourist.git
```
2. Install dependences (**CocoaPods needed for the project to work**)
```
pod install
```
3. Replace flicker API key inside -> (VirtualTourist/Model/API/FlickrAPI.swift) *I left my key in case you don't have one*

4. Open `VirtualTourist.xcworkspace` 

## How to use the app
- Launch the app using iOS Simulator
- A map is shown where you can search for location or long press the anywhere you want on the map then, a red pin will be added automatically.
- You can add as many pins as you want in different places on the map.
- Clicking on any pin to see random photos from Flickr API.
- Tapping on any photo will remove it from the CollectionView.
- To load new set of photos "Collection" just click on the "New Collection".
- Clicking on Edit button will allow you to remove a pin from your map.
- All added pins and loaded photos stored using CoreData.

## Resources
This app uses the following frameworks and APIs:

### Third-party frameworks

| Framework | Description |
| --- | --- 
| [Alamofire](https://github.com/Alamofire/Alamofire) | An Easy way to interface to HTTP network requests in Swift. |
| [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) | An easy way to deal with JSON data in Swift.|
| [Kingfisher](https://github.com/onevcat/Kingfisher) | A powerful, pure-Swift library for downloading and caching images from the web.|

### APIs
| Framework | Description |
| --- | --- |
| [Flickr API](https://www.flickr.com/services/api/flickr.photos.search.html) | To return a list of photos matching some criteria, based on the latitude & longitude of pin pressed. |
