//
//  DCPizzaApp.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 10/30/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import UIKit
import Domain
import Resolver

@main
struct DCPizzaApp: App, Resolving {
    @Environment(\.scenePhase) private var _phase
    private let _service: DCPizzaViewModel
    private let _mainViewModel: MenuListViewModel

    init() {
        // Create main (menu) view model.
        _mainViewModel = Resolver.resolve(MenuListViewModel.self)
        _service = Resolver.resolve(DCPizzaViewModel.self)

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
                .environmentObject(_mainViewModel)
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
