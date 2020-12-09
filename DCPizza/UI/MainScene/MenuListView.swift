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
import Resolver
import Introspect

struct MenuListView: View, Resolving {
    @InjectedObject private var _viewModel: MenuListViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(_viewModel.listData) { vm in
                    ZStack {
                        MenuRow(viewModel: vm)
                        NavigationLink(destination:
                            self.resolver.resolve(
                                IngredientsListView.self,
                                args: self._viewModel.pizza(at: vm.index)
                            )
                        ) {
                            EmptyView()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(PlainListStyle())
            .introspectTableView {
                $0.separatorStyle = .none
            }
            .navigationTitle(Text("NENNO'S PIZZA"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text("")
                        NavigationLink(
                            destination:
                            resolver.resolve(CartListView.self)
                                .environmentObject(resolver.resolve(CartViewModel.self))
                                .environmentObject(resolver.resolve(DrinksViewModel.self))
                        ) {
                            Image("ic_cart_navbar")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Text("")
                        NavigationLink(destination:
                            resolver.resolve(IngredientsListView.self,
                                             args: Just(Pizza()).eraseToAnyPublisher())
                        ) {
                            Image(systemName: "plus")
                                .accentColor(KColors.cTint)
                        }
                    }
                }
            }
            .sheet(isPresented: $_viewModel.showAdded) {
                AddedView()
            }
        }
    }
}

struct MenuListView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.switchToNetworkless()
        return Resolver.resolve(MenuListView.self)
    }
}
