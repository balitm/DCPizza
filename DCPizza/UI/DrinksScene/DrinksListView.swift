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

struct DrinksListView: View, Resolving {
    @Environment(\.presentationMode) private var _mode: Binding<PresentationMode>
    @ObservedObject private var _viewModel: DrinksViewModel

    init(viewModel: DrinksViewModel) {
        DLog(">>> inited: ", type(of: self))
        _viewModel = viewModel
    }

    var body: some View {
        List {
            ForEach(_viewModel.listData) { item in
                Button(action: {
                    self._viewModel.select(index: item.index)
                }) {
                    DrinkRow(viewModel: item)
                }
                .listRowInsets(EdgeInsets())
            }
        }
        .listSeparatorStyle(style: .singleLine)
        .navigationBarTitle(Text("DRINKS"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .backNavigationBarItems(_mode)
        .sheet(isPresented: $_viewModel.showAdded, content: {
            AddedView()
        })
    }
}

struct DrinksListView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.switchToNetworkless()
        return Resolver.resolve(DrinksListView.self)
    }
}
