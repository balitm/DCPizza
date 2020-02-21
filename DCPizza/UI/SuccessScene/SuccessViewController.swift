//
//  SuccessViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/21/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import RxSwift

private let _kUnwindSegue = "unwindToMenu"

final class SuccessViewController: UIViewController {
    private let _bag = DisposeBag()

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

        Observable<Int>.timer(.seconds(30), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.performSegue(withIdentifier: _kUnwindSegue, sender: nil)
            })
            .disposed(by: _bag)
    }
}
