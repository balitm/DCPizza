//
//  MenuRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/14/20.
//

import Foundation
import Combine

struct MenuRepository: MenuUseCase {
    private typealias _IndexedImage = (offset: Int, image: Image?)

    private enum _Event {
        case set(pizzas: Pizzas)
        case fetched(tuple: _IndexedImage)
    }

    private let _data: Initializer
    private let _imageInfo = PassthroughSubject<ImageInfo, Never>()
    private let _pizzas = PassthroughSubject<PizzasResult, Never>()
    private let _bag: Set<AnyCancellable>

    init(data: Initializer) {
        _data = data

        let event = PassthroughSubject<_Event, Never>()

        _bag = [
            _data.$component
                .receive(on: DS.dbQueue)
                .compactMap {
                    dispatchPrecondition(condition: .onQueue(DS.dbQueue))
                    guard let pizzas = try? $0.get().pizzas else { return nil }
                    return _Event.set(pizzas: pizzas)
                }
                .subscribe(event),

            _imageInfo
                .flatMap { info in
                    API.downloadImage(url: info.url)
                        .map { _Event.fetched(tuple: _IndexedImage(info.offset, $0)) }
                        .catch { _ in Empty<_Event, Never>() }
                }
                // .debug()
                .receive(on: DS.dbQueue)
                .subscribe(event),

            event
                .subscribe(on: DS.dbQueue)
                .scan(PizzasResult(pizzas: Pizzas.empty)) { (pr: PizzasResult, event: _Event) -> PizzasResult in
                    dispatchPrecondition(condition: .onQueue(DS.dbQueue))
                    switch event {
                    case let .set(pizzas):
                        return PizzasResult(pizzas: pizzas)
                    case let .fetched(tuple):
                        var pizzas = pr.pizzas.pizzas
                        let np = Pizza(copy: pizzas[tuple.offset], image: tuple.image)
                        pizzas[tuple.offset] = np
                        return PizzasResult(pizzas: Pizzas(pizzas: pizzas, basePrice: pr.pizzas.basePrice))
                    }
                }
                .receive(on: DispatchQueue.main)
                .subscribe(_pizzas),
        ]
    }

    var imageInfo: AnySubscriber<ImageInfo, Never> {
        AnySubscriber<ImageInfo, Never> {
            $0.request(.unlimited)
        } receiveValue: { [weak imageInfo = _imageInfo] in
            imageInfo?.send($0)
            return .unlimited
        } receiveCompletion: {
            DLog("Swallow ", $0)
        }
    }

    func pizzas() -> AnyPublisher<PizzasResult, Never> {
        _pizzas
            .eraseToAnyPublisher()
    }

    func addToCart(pizza: Pizza) -> AnyPublisher<Void, Error> {
        _data.cartHandler.trigger(action: .pizza(pizza: pizza))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
