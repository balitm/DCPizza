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

    var body: some View {
        NavigationView {
            List {
                ForEach(_viewModel.listData) { vm in
                    ZStack {
                        MenuRow(viewModel: vm)
                        NavigationLink(destination: AddedView()) {
                            EmptyView()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationBarTitle(Text("NENNO'S PIZZA"))
            .sheet(isPresented: $_viewModel.showAdded) {
                AddedView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
