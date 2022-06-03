//
//  AppDelegate.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 12/23/19.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// Tells the delegate that the launch process is almost done and the app is almost ready to run
    /// - Parameters:
    ///   - application: The singleton app object
    ///   - launchOptions: A dictionary indicating the reason the app was launched
    /// - Returns: False if the app cannot handle the URL resource or continue a user activity, otherwise return True
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print(DataSource.jsonURL.path)
        print(Locale(identifier: "en-US").localizedString(forLanguageCode: UserDefaults.standard.string(forKey: "i18n_language")!)!)
        if(UserDefaults.standard.string(forKey: "i18n_language") == nil) {
            UserDefaults.standard.set("en", forKey: "i18n_language")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    /// Retrieves the configuration data for UIKit to use when creating a new scene
    /// - Parameters:
    ///   - application: The singleton app object
    ///   - connectingSceneSession: The session object associated with the scene containing the initial configuration data loaded from the Info.plist file
    ///   - options: System-specific options for configuring the scene
    /// - Returns: The configuration object containing the information needed to create the scene
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    /// Tells the delegate that the user closed one or more of the app's scenes from the app switcher
    /// - Parameters:
    ///   - application: The singleton app object
    ///   - sceneSessions: The session objects associated with the discarded scenes
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

