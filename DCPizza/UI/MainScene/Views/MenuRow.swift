//
//  MenuRow.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/8/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct MenuRow: View {
    var viewModel: MenuRowViewModel

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Image("bg_wood")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 128)
                    .clipped()
                Spacer()
            }
            self.viewModel.image.map {
                $0
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 179)
                    .clipped()
            }
            VStack {
                Spacer()
                    .frame(height: 109)
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(viewModel.nameText)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(KColors.textColor)
                            Spacer()
                        }
                        Text(viewModel.ingredientsText)
                            .font(.system(size: 14))
                            .foregroundColor(KColors.textColor)
                    }
                    Spacer()
                        .frame(width: 30)
                    Button(action: {
                        self.viewModel.addToCart()
                    }) {
                        HStack {
                            Image("ic_cart_button")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 14, height: 14)
                                .scaledToFit()
                            Spacer()
                                .frame(width: 4)
                            Text(viewModel.priceText)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                        }
                        .frame(width: 64, height: 28)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: 0xFFCD2B)))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding()
                .background(Blur(style: .systemMaterialLight))
            }
        }
    }
}

struct MenuRow_Previews: PreviewProvider {
    static var previews: some View {
        let pizzas = PizzaData.pizzas
        return Group {
            MenuRow(viewModel: MenuRowViewModel(index: 0, basePrice: pizzas.basePrice, pizza: pizzas.pizzas[0]))
            MenuRow(viewModel: MenuRowViewModel(index: 1, basePrice: pizzas.basePrice, pizza: pizzas.pizzas[1]))
        }
        .previewLayout(.fixed(width: 300, height: 179))
    }
}
