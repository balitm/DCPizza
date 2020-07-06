//
//  PaddingRow.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/6/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI

struct PaddingRow: View {
    let viewModel: PaddingRowViewModel

    var body: some View {
        EmptyView()
            .frame(height: viewModel.height)
    }
}

struct PaddingRow_Previews: PreviewProvider {
    static var previews: some View {
        PaddingRow(viewModel: PaddingRowViewModel(height: 12))
    }
}
