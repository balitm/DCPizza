//
//  CartListView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/6/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Domain
import Resolver
// import Introspect

// private typealias _Item = CartViewModel.Item

struct CartListView: View {
    @Environment(\.presentationMode) private var _mode: Binding<PresentationMode>
    @ObservedObject private var _viewModel: CartViewModel

    init(viewModel: CartViewModel) {
        _viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                List {
                    Section(header: _ListHeader(), footer: _ListHeader()) {
                        ForEach(self._viewModel.listData) { item in
                            CartItemRow(viewModel: item)
                                .listRowInsets(EdgeInsets())
                        }
                    }

                    Section(header: _ListHeader(), footer: _ListHeader()) {
                        CartTotalRow(viewModel: self._viewModel.totalData)
                            .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(GroupedListStyle())
                .environment(\.defaultMinListRowHeight, 12)
                .environment(\.defaultMinListHeaderHeight, 12)

                // .introspectTableView { tableView in
                //     tableView.separatorStyle = .none
                //     // tableView.sectionHeaderHeight = 12
                //     // tableView.sectionFooterHeight = 12
                // }
                .listSeparatorStyle(style: .singleLine)

                _FooterView(geometry: geometry)
                    .environmentObject(self._viewModel)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle(Text("CART"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self._mode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .semibold))
        })
        .sheet(isPresented: $_viewModel.showSuccess, content: {
            SuccessView()
        })
    }
}

private struct _ListHeader: View {
    var body: some View {
        Rectangle()
            .frame(maxWidth: .infinity, maxHeight: 12)
            .foregroundColor(.yellow)
            .listRowInsets(EdgeInsets())
    }
}

private struct _ListFooter: View {
    var body: some View {
        Text("Remember to pack plenty of water and bring sunscreen.")
    }
}

private struct _FooterView: View {
    @EnvironmentObject private var _viewModel: CartViewModel
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                self._viewModel.checkout()
            }) {
                Text("CHECKOUT")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: geometry.size.width, height: 50)
                    .foregroundColor(self._viewModel.canCheckout ? .white : .gray)
            }
            .disabled(!self._viewModel.canCheckout)
            if geometry.safeAreaInsets.bottom > 0 {
                Spacer()
                    .frame(height: geometry.safeAreaInsets.bottom)
            }
        }
        .background(KColors.cTint)
    }
}

struct CartListView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.switchToNetworkless()
        return Resolver.resolve(CartListView.self)
    }
}
