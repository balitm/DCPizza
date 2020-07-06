//
//  ListSeparatorStyle.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/6/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI

struct ListSeparatorStyle: ViewModifier {
    let style: UITableViewCell.SeparatorStyle

    func body(content: Content) -> some View {
        content
            .onAppear {
                UITableView.appearance().separatorStyle = self.style
            }
    }
}

extension View {
    func listSeparatorStyle(style: UITableViewCell.SeparatorStyle) -> some View {
        ModifiedContent(content: self, modifier: ListSeparatorStyle(style: style))
    }
}
