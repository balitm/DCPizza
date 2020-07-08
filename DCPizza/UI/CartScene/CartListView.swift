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

private typealias _Item = CartViewModel.Item

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
                    ForEach(self._viewModel.listData) { item in
                        self._itemRow(item)
                            .listRowInsets(EdgeInsets())
                    }
                }
                .environment(\.defaultMinListRowHeight, 12)
                .listSeparatorStyle(style: .none)

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

    private func _itemRow(_ item: _Item) -> AnyView {
        switch item {
        case let .padding(viewModel):
            return AnyView(PaddingRow(viewModel: viewModel))
        case let .item(viewModel):
            return AnyView(
                Button(action: {
                    self._viewModel.selected = viewModel.index
                }) {
                    CartItemRow(viewModel: viewModel)
                }
            )
        case let .total(viewModel):
            return AnyView(CartTotalRow(viewModel: viewModel))
        }
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
