//
//  ViewControllerBase.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 05/11/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

import UIKit
import Domain

class ViewControllerBase: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    /// Hook function to override to set up and layout views.
    func setupViews() {}
}
