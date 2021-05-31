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
import Introspect

struct CartListView: View, Resolving {
    @Environment(\.presentationMode) private var _mode: Binding<PresentationMode>
    @StateObject private var _viewModel = Resolver.resolve(CartViewModel.self)

    init() {
        DLog(">>> inited: ", type(of: self))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        Section(header: _ListHeader(), footer: _ListHeader()) {
                            ForEach(self._viewModel.listData) { item in
                                Button {
                                    self._viewModel.select(index: item.index)
                                } label: {
                                    CartItemRow(viewModel: item)
                                        .listRowInsets(EdgeInsets())
                                }
                            }
                        }

                        Section(header: _ListHeader()) {
                            CartTotalRow(viewModel: self._viewModel.totalData)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                }

                _FooterView(viewModel: _viewModel, geometry: geometry)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle(Text("CART"))
            .navigationBarTitleDisplayMode(.inline)
            .backNavigationBarItems(
                _mode,
                trailing:
                NavigationLink(destination: resolver.resolve(DrinksListView.self)) {
                    Image("ic_drinks")
                }
                .isDetailLink(false)
            )
            .sheet(isPresented: $_viewModel.showSuccess) {
                SuccessView()
            }
        }
    }
}

private struct _ListHeader: View {
    var body: some View {
        Rectangle()
            .frame(maxWidth: .infinity, minHeight: 12, maxHeight: 12)
            .foregroundColor(Color(UIColor.systemBackground))
            .listRowInsets(EdgeInsets())
    }
}

private struct _FooterView: View {
    @ObservedObject var viewModel: CartViewModel
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: 0) {
            Text("CHECKOUT")
                .font(.system(size: 16, weight: .bold))
                .frame(width: geometry.size.width, height: 50)
                .foregroundColor(self.viewModel.canCheckout ? .white : .gray)
                .contentShape(Rectangle())
                .onTapGesture(perform: {
                    self.viewModel.checkout()
                })
                .disabled(!self.viewModel.canCheckout)

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
            .environmentObject(Resolver.resolve(CartViewModel.self))
            .environmentObject(Resolver.resolve(DrinksViewModel.self))
    }
}
