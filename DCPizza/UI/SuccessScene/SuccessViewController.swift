//
//  SuccessViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/21/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import Combine

private let _kUnwindSegue = "unwindToMenu"

final class SuccessViewController: UIViewController {
    private var _timerCancellable: AnyCancellable?

    class func create(with storyboard: UIStoryboard) -> SuccessViewController {
        let vc = storyboard.load(type: SuccessViewController.self)
        vc.isModalInPresentation = true
        return vc
    }

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        _timerCancellable = Timer.publish(every: 30, on: .main, in: .default)
            .autoconnect()
            .sink(receiveValue: { [unowned self] _ in
                self.performSegue(withIdentifier: _kUnwindSegue, sender: nil)
            })
    }
}
