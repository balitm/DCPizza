//
//  DCPizzaApp.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 10/30/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import UIKit
import Resolver
import AlamofireNetworkActivityIndicator

@main
struct DCPizzaApp: App, Resolving {
    @Environment(\.scenePhase) private var _phase
    private let _service: DCPizzaViewModel

    init() {
        _service = Resolver.resolve(DCPizzaViewModel.self)

        // Setup network indicator usage.
        NetworkActivityIndicatorManager.shared.startDelay = 0.0
        NetworkActivityIndicatorManager.shared.isEnabled = true

        // Set navigation bar appearance.
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: KColors.tint!,
        ]

        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: KColors.tint!,
            .font: UIFont.systemFont(ofSize: 17, weight: .heavy),
        ]

        UINavigationBar.appearance().tintColor = KColors.tint
    }

    var body: some Scene {
        WindowGroup {
            resolver.resolve(MenuListView.self)
        }
        .onChange(of: _phase) {
            switch $0 {
            case .active:
                break
            case .inactive:
                _service.saveCart()
            case .background:
                break
            @unknown default:
                break
            }
        }
    }
}
