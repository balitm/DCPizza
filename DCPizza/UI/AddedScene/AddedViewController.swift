//
//  AddedViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import RxSwift

final class AddedViewController: UIViewController {
    @IBOutlet weak var tapRecognizer: UITapGestureRecognizer!

    private let _bag = DisposeBag()

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tapRecognizer.rx.event
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .disposed(by: _bag)

        rx.viewDidAppear
            .flatMap({ _ in
                Observable<Int>.timer(.seconds(3), scheduler: MainScheduler.instance)
            })
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .disposed(by: _bag)
    }
}
