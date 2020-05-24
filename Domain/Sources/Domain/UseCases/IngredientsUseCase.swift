//
//  IngredientsUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/15/20.
//

import Foundation
import Combine
import class AlamofireImage.Image

public protocol IngredientsUseCase {
    func ingredients(selected: AnyPublisher<Int, Never>) -> AnyPublisher<[IngredientSelection], Never>
    func addToCart() -> AnyPublisher<Void, Error>
    func name() -> AnyPublisher<String, Never>
    func image() -> AnyPublisher<Image?, Never>
}
