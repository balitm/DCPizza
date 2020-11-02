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
    @EnvironmentObject private var _viewModel: CartViewModel
    @EnvironmentObject private var _drinksViewModel: DrinksViewModel

    init() {
        DLog(">>> inited: ", type(of: self))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                List {
                    Section(header: _ListHeader(), footer: _ListHeader()) {
                        ForEach(self._viewModel.listData) { item in
                            Button(action: {
                                self._viewModel.select(index: item.index)
                            }) {
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
                .listStyle(GroupedListStyle())
                .environment(\.defaultMinListHeaderHeight, 12)
                .introspectTableView {
                    $0.separatorStyle = .none
                    $0.backgroundColor = .clear
                    $0.backgroundView = nil
                }

                _FooterView(geometry: geometry)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle(Text("CART"))
            .navigationBarTitleDisplayMode(.inline)
            .backNavigationBarItems(
                _mode,
                trailing:
                NavigationLink(destination: resolver.resolve(DrinksListView.self)
                    .environmentObject(_drinksViewModel)
                ) {
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
            .frame(maxWidth: .infinity, maxHeight: 12)
            .foregroundColor(Color(UIColor.systemBackground))
            .listRowInsets(EdgeInsets())
    }
}

private struct _FooterView: View {
    @EnvironmentObject private var _viewModel: CartViewModel
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: 0) {
            Text("CHECKOUT")
                .font(.system(size: 16, weight: .bold))
                .frame(width: geometry.size.width, height: 50)
                .foregroundColor(self._viewModel.canCheckout ? .white : .gray)
                .contentShape(Rectangle())
                .onTapGesture(perform: {
                    self._viewModel.checkout()
                })
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
            .environmentObject(Resolver.resolve(CartViewModel.self))
            .environmentObject(Resolver.resolve(DrinksViewModel.self))
    }
}
