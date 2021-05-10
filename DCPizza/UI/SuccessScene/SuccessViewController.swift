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
import Stevia

private let _kUnwindSegue = "unwindToMenu"

final class SuccessViewController: UIViewController {
    private var _cancellable: AnyCancellable?

    init() {
        super.init(nibName: nil, bundle: nil)
        isModalInPresentation = true
        _setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(tapRecognizer)

        _cancellable = Publishers.Merge(
            tapRecognizer.cmb.event()
                .map { _ in () },
            Timer.publish(every: 30, on: .main, in: .default)
                .autoconnect()
                .map { _ in () })
            .sink { [weak self] _ in
                let presenting = self?.presentingViewController as? UINavigationController
                self?.dismiss(animated: true) {
                    presenting?.popViewController(animated: true)
                }
            }
    }
}

private extension SuccessViewController {
    func _setupViews() {
        view.style { v in
            v.backgroundColor = .clear
        }

        let footerView = UIView()
        let label0 = UILabel()
        let label1 = UILabel()
        let stacView = UIStackView(arrangedSubviews: [label0, label1])
        let bodyView = UIView()

        // Set up views.
        footerView.style { v in
            v.backgroundColor = UIColor(.tint)
        }

        label0.style { l in
            l.textColor = UIColor(.tint)
            l.text = "Thank you"
            l.font = UIFont.italicSystemFont(ofSize: 34)
        }
        label1.style { l in
            l.textColor = UIColor(.tint)
            l.text = "for your order!"
            l.font = UIFont.italicSystemFont(ofSize: 34)
        }
        stacView.style { s in
            s.axis = .vertical
            s.alignment = .center
            s.distribution = .fill
        }

        bodyView.style { v in
            v.backgroundColor = .systemBackground
        }

        bodyView.subviews {
            stacView
        }
        view.subviews {
            bodyView
            footerView
        }

        // Set up layout.
        bodyView.leading(0).trailing(0)
        bodyView.Top == view.safeAreaLayoutGuide.Top
        stacView.centerInContainer()
        footerView.height(90)
        footerView.Top == bodyView.Bottom
        footerView.leading(0).trailing(0)
        footerView.Top == view.safeAreaLayoutGuide.Bottom - 50
    }
}
