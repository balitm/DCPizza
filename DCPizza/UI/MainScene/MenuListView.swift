//
//  MenuListView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/9/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Combine
import Domain

struct MenuListView: View {
    @EnvironmentObject private var _viewModel: MenuListViewModel
    let ingredientsFactory: AppDependencyContainer

    var body: some View {
        NavigationView {
            List {
                ForEach(_viewModel.listData) { vm in
                    ZStack {
                        MenuRow(viewModel: vm)
                        NavigationLink(destination:
                            self.ingredientsFactory
                                .makeIngredientsView(
                                    pizza: self._viewModel.pizza(at: vm.index)
                                )
                        ) {
                            EmptyView()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationBarTitle("NENNO'S PIZZA")
            .navigationBarItems(trailing: NavigationLink(destination:
                self.ingredientsFactory
                    .makeIngredientsView(pizza: Just(Pizza()).eraseToAnyPublisher())
            ) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $_viewModel.showAdded) {
                AddedView()
            }
        }
    }
}

struct MenuListView_Previews: PreviewProvider {
    static var previews: some View {
        let service = NetworklessUseCaseProvider().makeMenuUseCase()
        let viewModel = MenuListViewModel(service: service)

        return MenuListView(ingredientsFactory: AppDependencyContainer())
            .environmentObject(viewModel)
    }
}
