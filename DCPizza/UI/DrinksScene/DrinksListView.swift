//
//  DrinksListView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/10/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Resolver

struct DrinksListView: View {
    @Environment(\.presentationMode) private var _mode: Binding<PresentationMode>
    @InjectedObject private var _viewModel: DrinksViewModel

    var body: some View {
        List(_viewModel.listData) { item in
            DrinkRow(viewModel: item)
        }
        .listSeparatorStyle(style: .singleLine)
        .navigationBarTitle(Text("DRINKS"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self._mode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .semibold))
        })
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
