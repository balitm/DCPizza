//
//  API.swift
//  Domain
//
//  Created by Balázs Kilvády on 7/14/17.
//  Copyright © 2017 Balázs Kilvády. All rights reserved.
//

import Foundation
import Combine
import class UIKit.UIImage

private let _kBaseUrl = URL(string: "https://api.jsonbin.io/v3/b/")!

public enum API {
    public enum ErrorType: Error {
        case invalidURL
        case disabled
        case invalidJSON
        case processingFailed
        case status(code: Int)
        case connectionLost
        case netError(error: Error?)
    }

    static let _decoder = _createDecoder()

    static func getIngredients() -> AnyPublisher<[DS.Ingredient], ErrorType> {
        let url = Self._createGetURL("5e91eda1172eb64389622c7a")
        return _fetch(url)
    }

    static func getDrinks() -> AnyPublisher<[DS.Drink], ErrorType> {
        let url = Self._createGetURL("5e91ef298e85c84370147b21")
        return _fetch(url)
    }

    static func getPizzas() -> AnyPublisher<DS.Pizzas, ErrorType> {
        let url = Self._createGetURL("5e91f1a0cc62be4369c2e408")
        return _fetch(url)
    }

    static func checkout(pizzas: [DS.Pizza], drinks: [DS.Drink.ID]) -> AnyPublisher<Void, ErrorType> {
        let url = Self._createPostURL(_Checkout(pizzas: pizzas, drinks: drinks))
        return _post(url)
    }

    static func downloadImage(url: URL) -> AnyPublisher<Image, ErrorType> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap {
                guard let image = Image(data: $0.data) else {
                    throw ErrorType.processingFailed
                }
                return image
            }
            .mapError { _ in ErrorType.processingFailed }
            .eraseToAnyPublisher()
    }
}

private extension API {
    struct _Record<D: Decodable>: Decodable {
        let record: D
    }

    static func _fetch<D: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<D, ErrorType> {
        DLog("url: ", urlRequest.url?.absoluteString ?? "nil")

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else { fatalError() }
                guard response.statusCode == 200 else {
                    throw ErrorType.status(code: response.statusCode)
                }
                // DLog("output of ", urlRequest.url?.absoluteString ?? "nil", "\n", output.data.count, "\n",
                //      String(decoding: output.data, as: UTF8.self))
                return output.data
            }
            .decode(type: _Record<D>.self, decoder: _decoder)
            .mapError { error -> ErrorType in
                DLog("url: ", urlRequest.url?.absoluteString ?? "nil", ", type: ", D.self)
                DLog("fetch error: ", error)
                if let httpError = error as? ErrorType {
                    return httpError
                }
                return ErrorType.processingFailed
            }
            .map(\.record)
            .eraseToAnyPublisher()
    }

    static func _post(_ urlRequest: URLRequest) -> AnyPublisher<Void, ErrorType> {
        DLog("url: ", urlRequest.url?.absoluteString ?? "nil")

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else { fatalError() }
                guard response.statusCode == 200 else {
                    throw ErrorType.status(code: response.statusCode)
                }
                return ()
            }
            .mapError { error -> ErrorType in
                DLog("fetch error: ", error)
                if let httpError = error as? ErrorType {
                    return httpError
                }
                return ErrorType.processingFailed
            }
            .eraseToAnyPublisher()
    }

    static func _createGetURL(_ path: String) -> URLRequest {
        // Assembling the url.
        guard let url = URL(string: path, relativeTo: _kBaseUrl) else { fatalError() }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

        // Set up the reqest.
        var request = URLRequest(url: components.url!, timeoutInterval: 30)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }

    static func _createPostURL(_ parameters: some Encodable) -> URLRequest {
        // Assembling the url.
        guard let url = URL(string: "http://httpbin.org/post") else { fatalError() }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

        // Set up the reqest.
        var request = URLRequest(url: components.url!, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(parameters)
            request.httpBody = encoded
        } catch {
            DLog(">>> encode failed with: ", error)
        }

        return request
    }

    static func _createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
}

private struct _Checkout: Encodable {
    let pizzas: [DS.Pizza]
    let drinks: [DS.Drink.ID]
}
