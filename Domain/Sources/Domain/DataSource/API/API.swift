//
//  API.swift
//  Domain
//
//  Created by Balázs Kilvády on 7/14/17.
//  Copyright © 2017 Balázs Kilvády. All rights reserved.
//

import Foundation
import Combine
import Alamofire
import AlamofireImage

private let _kBaseUrl = URL(string: "https://api.jsonbin.io/b/")!
private let _kGetHeader: HTTPHeaders = [
    "application/json": "Accept",
]

private let _kPostHeader: HTTPHeaders = [
    "Accept": "application/json",
    "Content-Type": "application/json",
]

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
        let url = Self._createPostURL()
        return _post(url, _Checkout(pizzas: pizzas, drinks: drinks))
    }

    static func downloadImage(url: URL) -> AnyPublisher<Image, ErrorType> {
        imageDownloader.image(for: url)
    }
}

private extension API {
    static func _fetch<D: Decodable>(_ url: URL) -> AnyPublisher<D, ErrorType> {
        DLog("url: ", url.absoluteString)

        return AF.request(url, headers: _kGetHeader) {
            $0.timeoutInterval = 30
        }
        .publishDecodable(type: D.self, queue: DispatchQueue.main, decoder: _decoder)
        .tryMap { output in
            switch output.result {
            case let .failure(afError):
                if case let AFError.sessionTaskFailed(error) = afError {
                    throw ErrorType.netError(error: error)
                } else {
                    throw ErrorType.processingFailed
                }
            case let .success(value):
                return value
            }
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

    static func _post<E: Encodable>(_ url: URL, _ parameters: E) -> AnyPublisher<Void, ErrorType> {
        DLog("url: ", url.absoluteString)

        return AF.request(url,
                          method: .post,
                          parameters: parameters,
                          encoder: JSONParameterEncoder.default,
                          headers: _kPostHeader) {
            $0.timeoutInterval = 30
        }
        .publishUnserialized(queue: DispatchQueue.main)
        .tryMap { output in
            switch output.result {
            case let .failure(afError):
                if case let AFError.sessionTaskFailed(error) = afError {
                    throw ErrorType.netError(error: error)
                } else {
                    throw ErrorType.processingFailed
                }
            case .success:
                return ()
            }
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

    static func _createGetURL(_ path: String) -> URL {
        guard let url = URL(string: path, relativeTo: _kBaseUrl) else { fatalError() }
        return url
    }

    static func _createPostURL() -> URL {
        guard let url = URL(string: "http://httpbin.org/post") else { fatalError() }
        return url
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

private let imageDownloader: ImageDownloader = {
    let sessionConfig = ImageDownloader.defaultURLSessionConfiguration()
    sessionConfig.urlCache = nil
    return ImageDownloader(
        configuration: sessionConfig,
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 2,
        imageCache: nil
    )
}()

private extension ImageDownloader {
    func image(for url: URL) -> AnyPublisher<Image, API.ErrorType> {
        Future<Image, API.ErrorType> { subscriber in
            let urlRequest = URLRequest(url: url)
            imageDownloader.download(urlRequest, completion: { response in
                if let image = response.value {
                    subscriber(.success(image))
                } else {
                    subscriber(.failure(API.ErrorType.processingFailed))
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
