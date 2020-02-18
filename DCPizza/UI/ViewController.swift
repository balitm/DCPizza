//
//  ViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import RxSwift

class ViewController: UIViewController {
    private let _bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let useCase = NetworkUseCase()
        useCase.getIngredients()
            .subscribe()
            .disposed(by: _bag)

        useCase.getDrinks()
            .subscribe()
            .disposed(by: _bag)

        useCase.getPizzas()
            .subscribe()
            .disposed(by: _bag)
    }
}
