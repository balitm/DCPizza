//
//  AddedView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/12/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI

struct AddedView: View {
    @Environment(\.presentationMode) private var _mode: Binding<PresentationMode>

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Text("ADDED TO CART")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: proxy.size.width - 32, height: 20)
                    .background(KColors.cTint)
                Spacer()
            }
            .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
            .contentShape(Rectangle())
            .onTapGesture {
                self._mode.wrappedValue.dismiss()
            }
        }
    }
}

struct AddedView_Previews: PreviewProvider {
    static var previews: some View {
        AddedView()
    }
}
