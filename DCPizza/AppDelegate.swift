//
//  AppDelegate.swift
//  Creative
//
//  Created by Bali on 12/6/14.
//  Copyright (c) 2014 kil-dev. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityIndicator

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NetworkActivityIndicatorManager.shared.startDelay = 0.0
        NetworkActivityIndicatorManager.shared.isEnabled = true
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        _saveCart()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        _saveCart()
    }

    private func _saveCart() {
        guard let nc = window?.rootViewController as? UINavigationController else { return }
        guard let menuVC = nc.viewControllers.first as? MenuTableViewController else { return }
        menuVC.saveCart()
    }
}
