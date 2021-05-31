//
//  DrinksListView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/10/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Resolver
import Domain
import Introspect

struct DrinksListView: View {
    @Environment(\.presentationMode) private var _mode: Binding<PresentationMode>
    @StateObject private var _viewModel = Resolver.resolve(DrinksViewModel.self)

    var body: some View {
        List {
            ForEach(_viewModel.listData) { item in
                Button {
                    self._viewModel.removeFromCart(index: item.index)
                } label: {
                    DrinkRow(viewModel: item)
                }
                .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(PlainListStyle())
        .introspectTableView(customize: {
            $0.separatorStyle = .singleLine
            $0.tableFooterView = UIView()
        })
        .navigationTitle(Text("DRINKS"))
        .navigationBarTitleDisplayMode(.inline)
        .backNavigationBarItems(_mode)
        .sheet(isPresented: $_viewModel.showAdded) {
            AddedView()
        }
    }
}

struct DrinksListView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.switchToNetworkless()
        return Resolver.resolve(DrinksListView.self)
            .environmentObject(Resolver.resolve(DrinksViewModel.self))
    }
}
