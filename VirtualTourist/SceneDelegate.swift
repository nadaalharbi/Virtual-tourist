import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let dataController = DataController(modelName:"VirtualTourist")
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        self.dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let mapViewController = navigationController.topViewController as! TravelLocationsMapView
        mapViewController.dataController = dataController
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { saveViewContext()}
    
    func sceneDidBecomeActive(_ scene: UIScene) { saveViewContext()}
    
    func sceneWillResignActive(_ scene: UIScene) { saveViewContext()}
    
    func sceneWillEnterForeground(_ scene: UIScene) { saveViewContext()}
    
    func sceneDidEnterBackground(_ scene: UIScene) { saveViewContext()}
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
}
