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
    @EnvironmentObject private var _viewModel: MenuListViewModel

    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: KColors.tint,
        ]

        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: KColors.tint,
            .font: UIFont.systemFont(ofSize: 17, weight: .heavy),
        ]
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(_viewModel.tableData) { vm in
                    MenuRow(viewModel: vm)
                        .listRowInsets(EdgeInsets())
                }
            }
            .navigationBarTitle(Text("NENNO'S PIZZA"))
        }
    }
}

struct MenuListView_Previews: PreviewProvider {
    static var previews: some View {
        let service = NetworklessUseCaseProvider().makeMenuUseCase()
        let viewModel = MenuListViewModel(service: service)

        return MenuListView()
            .environmentObject(viewModel)
    }
}
