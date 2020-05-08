//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Tony Mackay on 07/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let dataController = DataController(modelName: Strings.modelName)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkIfFirstLaunch()
        dataController.load()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: Strings.hasLaunchedBefore) {
            print("App has launched before")
        } else {
            print("This is the first launch ever!")
            
            // default region to UK
            UserDefaults.standard.set(true, forKey: Strings.hasLaunchedBefore)
            UserDefaults.standard.set(54.43332437523645, forKey: Strings.latitude)
            UserDefaults.standard.set(-2.7997356778451206, forKey: Strings.longitude)
            UserDefaults.standard.set(7.6347000067807755, forKey: Strings.latitudeDelta)
            UserDefaults.standard.set(6.701326754381938, forKey: Strings.longitudeDelta)
            UserDefaults.standard.synchronize()
        }
    }
}
