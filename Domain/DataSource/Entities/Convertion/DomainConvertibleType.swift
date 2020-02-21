//
//  DomainConvertibleType.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

protocol DomainConvertibleType {
    associatedtype DomainType

    func asDomain(with ingredients: [DS.Ingredient], drinks: [DS.Drink]) -> DomainType
}
