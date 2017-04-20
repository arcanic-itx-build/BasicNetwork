


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let network = BasicNetwork()

        network.request(endPoint: BasicNetwork.EndPoint("posts","101"), parameters: nil, method: .get) { (response) in
            switch response {
            case .error(let error, let report):
                print("ERROR")
                print(error)
                print(report.prettyPrint())
            case .success(let json,let report):
                print("Success")
                print(json)
                print(report.prettyPrint())
            }
        }
        
        let parameters:[String:Any] = [
            "title" : "bingo",
            "body" : "bongo",
            "userId": 23
        ]
        
        network.request(endPoint: BasicNetwork.EndPoint("posts"), parameters: parameters, method: .post, completionHandler: BasicNetwork.defaultCompletionHandler)
        return true
    }


}

