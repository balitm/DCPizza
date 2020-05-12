//
//  AddedViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import Combine

final class AddedViewController: UIViewController {
    @IBOutlet weak var tapRecognizer: UITapGestureRecognizer!

    private var _bag = Set<AnyCancellable>()

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tapRecognizer.cmb.event()
            .sink(receiveValue: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .store(in: &_bag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Timer.publish(every: 3, on: .main, in: .default)
            .autoconnect()
            .first()
            .sink(receiveValue: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .store(in: &_bag)
    }
}
