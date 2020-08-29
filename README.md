# Virtual-tourist
Virtual Tourist in an app to show a map with ability to add pins anywher and load amazing photos of the tapped location - pin!
This project is build for my iOS Nanodegree program - Udacity

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
- Launch the app usingiOS Simulator
- A map is shown where you can long press the location anywhere you want, a red pin will add automatically.
- You can as many pins as you want in different places on the map.
- Clicking on any pin to see random photos from Flickr API.
- Tapping on any photo will remove it from the CollectionView.
- To load new set of photos "Collection" just click on the "New Collection".
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
