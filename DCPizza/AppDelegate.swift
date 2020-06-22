//
//  AppDelegate.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/9/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup network indicator usage.
        NetworkActivityIndicatorManager.shared.startDelay = 0.0
        NetworkActivityIndicatorManager.shared.isEnabled = true

        // Set navigation bar appearance.
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: KColors.tint,
        ]

        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: KColors.tint,
            .font: UIFont.systemFont(ofSize: 17, weight: .heavy),
        ]

        UINavigationBar.appearance().tintColor = KColors.tint

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
