//
//  MenuListView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/9/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct MenuListView: View {
    @EnvironmentObject private var _viewModel: MenuTableViewModel

    init() {
        // 2.
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: KColors.tint,
        ]

        // 3.
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .heavy),
        ]
    }

    var body: some View {
        NavigationView {
            List(_viewModel.tableData) { vm in
                MenuRow(viewModel: vm)
            }
            .navigationBarTitle(Text("NENNO'S PIZZA"))
        }
    }
}

struct MenuListView_Previews: PreviewProvider {
    static var previews: some View {
        let service = NetworklessUseCaseProvider().makeMenuUseCase()
        let viewModel = MenuTableViewModel(service: service)

        return MenuListView()
            .environmentObject(viewModel)
    }
}
