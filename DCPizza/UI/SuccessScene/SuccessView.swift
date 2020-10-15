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
                VStack {
                    Spacer()
                    self._text("Thank you")
                    self._text("for your order!")
                    Spacer()
                }
                .background(Color(UIColor.systemBackground))

                _FooterView(geometry: proxy)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                self._mode.wrappedValue.dismiss()
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    private func _text(_ string: String) -> Text {
        Text(string)
            .font(.system(size: 34)).italic()
            .foregroundColor(KColors.cTint)
    }
}

private struct _FooterView: View {
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(KColors.cTint)
                .frame(width: geometry.size.width, height: 50 + geometry.safeAreaInsets.bottom)
        }
        .background(KColors.cTint)
    }
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView()
    }
}
