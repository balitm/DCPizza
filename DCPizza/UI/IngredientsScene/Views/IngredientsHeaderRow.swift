//
//  IngredientsHeaderRow.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/21/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct IngredientsHeaderRow: View {
    let viewModel: IngredientsHeaderRowViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Image("bg_wood")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()
                viewModel.image.map {
                    $0
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                }
            }
            Text("Ingredients")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(KColors.textColor)
                .padding(12)
        }
    }
}

struct IngredientsHeaderRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            IngredientsHeaderRow(viewModel: IngredientsHeaderRowViewModel(image: nil))
        }
        .previewLayout(.fixed(width: 375, height: 365))
    }
}
