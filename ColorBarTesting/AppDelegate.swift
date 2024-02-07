//
//  AppDelegate.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2022/10/24.
//

import UIKit
import CloudKit
import UserNotifications

let localFileManager = LocalFileManager.shared
let mlModelManager = MLModelManager.shared
let newsSettingManager = NewsSettingManager.shared
let utils = Utils.shared
let userDefaults = UserDefaults.standard
let userDefaultsWidget = UserDefaults(suiteName: UserdefaultsGroup.widgetShared.rawValue)
let cloudDefaults = NSUbiquitousKeyValueStore.default
let localNotification = UNUserNotificationCenter.current()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        cloudDefaults.synchronize()
        checkIcloudState()
        
        localNotification.requestAuthorization(options: [.alert, .badge]) { isGet, error in
            print(isGet, error)
        }
        
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


}

