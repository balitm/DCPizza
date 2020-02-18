//
//  UIStoryboard+load.swift
//
//  Created by Balázs Kilvády on 7/17/18.
//  Copyright © 2018 Balázs Kilvády. All rights reserved.
//

import UIKit

extension UIStoryboard {
    class func load<Controller: UIViewController>(from storyboard: String, type: Controller.Type, identifier: String? = nil, isInit: Bool = false) -> Controller {
        let sboard = UIStoryboard(name: storyboard, bundle: nil)
        return sboard.load(type: type, identifier: identifier, isInit: isInit)
    }

    func load<Controller: UIViewController>(type: Controller.Type, identifier: String? = nil, isInit: Bool = false) -> Controller {
        if isInit {
            return instantiateInitialViewController() as! Controller
        }
        let identifier = identifier ?? NSStringFromClass(Controller.self).components(separatedBy: ".").last ?? ""
        return instantiateViewController(withIdentifier: identifier) as! Controller
    }
}
