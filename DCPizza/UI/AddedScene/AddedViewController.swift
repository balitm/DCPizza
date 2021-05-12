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
import Stevia

final class AddedViewController: ViewControllerBase {
    private var _bag = Set<AnyCancellable>()

    override init() {
        super.init()
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(tapRecognizer)

        tapRecognizer.cmb.event()
            .sink { [unowned self] _ in
                self.dismiss(animated: true)
            }
            .store(in: &_bag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Timer.publish(every: 3, on: .main, in: .default)
            .autoconnect()
            .first()
            .sink { [unowned self] _ in
                self.dismiss(animated: true)
            }
            .store(in: &_bag)
    }

    override func setupViews() {
        view.style { v in
            v.backgroundColor = .clear
        }

        let headerView = UIView()
        let headerLabel = UILabel()
        let bodyView = UIView()

        // Set up views.
        headerView.style { v in
            v.backgroundColor = UIColor(.tint)
        }

        headerLabel.style { l in
            l.textColor = UIColor(.price)
            l.text = "ADDED TO CART"
            l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        }

        bodyView.style { v in
            v.backgroundColor = .systemBackground
            v.alpha = 0.7
        }

        headerView.subviews {
            headerLabel
        }
        view.subviews {
            headerView
            bodyView
        }

        // Set up layout.
        headerLabel.top(3).bottom(2).centerHorizontally()
        headerView.left(0).right(0)
        headerView.Top == view.safeAreaLayoutGuide.Top
        headerView.Bottom == bodyView.Top
        bodyView.left(0).right(0).bottom(0)
    }
}
