//
//  IngredientsItemRow.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/21/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct IngredientsItemRow: View {
    let viewModel: IngredientsItemRowViewModel

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "checkmark")
                .foregroundColor(KColors.cTint)
                .font(.system(size: 10, weight: .bold))
                .frame(width: 54)
                .opacity(viewModel.isContained ? 1.0 : 0.0)
            Text(viewModel.name)
                .foregroundColor(KColors.textColor)
            Spacer()
            Text(viewModel.priceText)
                .foregroundColor(KColors.textColor)
            Spacer()
                .frame(width: 12)
        }
        .frame(height: 44)
    }
}

#if DEBUG
    struct IngredientsItemRow_Previews: PreviewProvider {
        static var previews: some View {
            let pizzas = PizzaData.pizzas
            return Group {
                IngredientsItemRow(viewModel: IngredientsItemRowViewModel(
                    name: pizzas.pizzas[0].ingredients[0].name,
                    priceText: "$" + String(pizzas.pizzas[0].ingredients[0].price),
                    isContained: true,
                    index: 0)
                )
                IngredientsItemRow(viewModel: IngredientsItemRowViewModel(
                    name: pizzas.pizzas[0].ingredients[1].name,
                    priceText: "$" + String(pizzas.pizzas[0].ingredients[1].price),
                    isContained: false,
                    index: 1)
                )
            }
            .previewLayout(.fixed(width: 375, height: 44))
        }
    }
#endif
