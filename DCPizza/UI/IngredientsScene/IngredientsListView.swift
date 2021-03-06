//
//  IngredientsListView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Combine
import Domain
import Resolver

struct IngredientsListView: View {
    @Environment(\.presentationMode) private var _mode: Binding<PresentationMode>
    @StateObject var viewModel: IngredientsViewModel
    @State private var _isShowFooter = false

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                List {
                    IngredientsHeaderRow(viewModel: self.viewModel.headerData)
                        .listRowInsets(EdgeInsets())
                    ForEach(self.viewModel.listData) { vm in
                        Button(action: {
                            self.viewModel.selected = vm.index
                        }) {
                            IngredientsItemRow(viewModel: vm)
                        }
                        .listRowInsets(EdgeInsets())
                        // .buttonStyle(PlainButtonStyle())
                    }
                }
                .introspectTableView {
                    $0.separatorStyle = .singleLine
                }

                if self._isShowFooter {
                    _FooterView(geometry: geometry)
                        .transition(.move(edge: .bottom))
                        .environmentObject(self.viewModel)
                }
            }
        }
        .onReceive(viewModel.footerEvent, perform: { event in
            withAnimation {
                self._isShowFooter = event == .show
            }
        })
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .backNavigationBarItems(_mode)
        .sheet(isPresented: $viewModel.showAdded) {
            AddedView()
        }
        .onAppear {
            self.viewModel.isAppeared = ()
        }
    }
}

private struct _FooterView: View {
    @EnvironmentObject private var _viewModel: IngredientsViewModel
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                self._viewModel.addToCart()
            }) {
                Text(_viewModel.cartText)
                    .frame(width: geometry.size.width, height: 50)
                    .foregroundColor(KColors.price)
            }
            if geometry.safeAreaInsets.bottom > 0 {
                Spacer()
                    .frame(height: geometry.safeAreaInsets.bottom)
            }
        }
        .background(KColors.yellow)
    }
}

struct IngredientsListView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.switchToNetworkless()
        let pizza = Just(PizzaData.pizzas.pizzas[0]).eraseToAnyPublisher()
        return Resolver.resolve(IngredientsListView.self, args: pizza)
    }
}
