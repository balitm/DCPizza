//
//  AddedViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import RxSwift

final class AddedViewController: UIViewController {
    private let _bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable<Int>.timer(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .disposed(by: _bag)
    }
}
