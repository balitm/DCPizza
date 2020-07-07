//
//  SuccessView.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/7/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI

struct SuccessView: View {
    @Environment(\.presentationMode) private var _mode: Binding<PresentationMode>

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                Text("Thank you")
                    .font(.system(size: 34)).italic()
                    .foregroundColor(KColors.cTint)
                Text("for your order!")
                    .font(.system(size: 34)).italic()
                    .foregroundColor(KColors.cTint)
                Spacer()

                _FooterView(geometry: proxy)
            }
            .background(Color.white)
            .onTapGesture {
                self._mode.wrappedValue.dismiss()
            }
        }
    }
}

private struct _FooterView: View {
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(KColors.cTint)
                .frame(width: geometry.size.width, height: 50)
            if geometry.safeAreaInsets.bottom > 0 {
                Spacer()
                    .frame(height: geometry.safeAreaInsets.bottom)
            }
        }
        .background(KColors.cTint)
    }
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView()
    }
}
