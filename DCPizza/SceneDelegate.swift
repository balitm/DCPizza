//
//  SceneDelegate.swift
//  Movies
//
//  Created by Balázs Kilvády on 04/12/21.
//

import UIKit
import Combine
import Domain

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let _injectionContainer = AppDependencyContainer()
    private var _bag = Set<AnyCancellable>()
    private lazy var _service: SaveUseCase = {
        _injectionContainer.makeSaveService()
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let nc = _rootNavigationController
        window.rootViewController = nc
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        _saveCart()
    }

    private func _saveCart() {
        _service.saveCart()
            .catch { _ in Empty<Void, Never>() }
            .sink {}
            .store(in: &_bag)
    }

    private var _rootNavigationController: UINavigationController {
        let nc = UINavigationController()
        let navigator = _injectionContainer.makeNavigator(by: nc)
        let vc = MenuTableViewController(navigator: navigator,
                                         viewModel: _injectionContainer.makeMenuTableViewModel())
        nc.pushViewController(vc, animated: false)
        nc.navigationBar.prefersLargeTitles = true
        nc.navigationBar.barStyle = .default
        return nc
    }
}
