//
//  BackModifier.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI

extension View {
    func backNavigationBarItems<T>(_ mode: Binding<PresentationMode>, trailing: T) -> some View where T: View {
        let backButton = Button(action: {
            mode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .semibold))
        }
        return navigationBarItems(leading: backButton, trailing: trailing)
    }

    func backNavigationBarItems(_ mode: Binding<PresentationMode>) -> some View {
        let backButton = Button(action: {
            mode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .semibold))
        }
        return navigationBarItems(leading: backButton)
    }
}
