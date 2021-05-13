//
//  AppDelegate.swift
//  Creative
//
//  Created by Bali on 12/6/14.
//  Copyright (c) 2020 kil-dev. All rights reserved.
//

import UIKit
import Combine
import Domain
import AlamofireNetworkActivityIndicator

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private let _injectionContainer = AppDependencyContainer()
    private var _bag = Set<AnyCancellable>()
    private lazy var _service: SaveUseCase = {
        _injectionContainer.makeSaveService()
    }()

    class var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NetworkActivityIndicatorManager.shared.startDelay = 0.0
        NetworkActivityIndicatorManager.shared.isEnabled = true

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = _navigationController
        self.window = window
        window.makeKeyAndVisible()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        _saveCart()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        _saveCart()
    }

    private func _saveCart() {
        _service.saveCart()
            .catch { _ in Empty<Void, Never>() }
            .sink {}
            .store(in: &_bag)
    }

    private var _navigationController: UINavigationController {
        let nc = UINavigationController()
        // Set navigation bar appearance.
        let tintColor = UIColor(.tint)
        nc.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: tintColor,
        ]

        nc.navigationBar.titleTextAttributes = [
            .foregroundColor: tintColor,
            .font: UIFont.systemFont(ofSize: 17, weight: .heavy),
        ]

        nc.navigationBar.tintColor = tintColor
        nc.navigationBar.prefersLargeTitles = true

        let navigator = _injectionContainer.makeNavigator(by: nc)
        let vc = MenuViewController(navigator: navigator,
                                    viewModel: _injectionContainer.makeMenuTableViewModel())
        nc.pushViewController(vc, animated: false)
        return nc
    }
}
