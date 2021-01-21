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
        guard let menuViewController = _menuViewController else { return false }
        menuViewController.setup(with: _injectionContainer.makeNavigator(by: menuViewController),
                                 viewModel: _injectionContainer.makeMenuTableViewModel())
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

    private var _menuViewController: MenuTableViewController? {
        guard let nc = window?.rootViewController as? UINavigationController
            , let menuVC = nc.viewControllers.first as? MenuTableViewController else { return nil }
        return menuVC
    }
}
