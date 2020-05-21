//
//  RequestProtocols.swift
//  Domain
//
//  Created by Balázs Kilvády on 7/29/17.
//  Copyright © 2017 Balázs Kilvády. All rights reserved.
//

import Foundation
import Alamofire
import Combine

protocol RequestReportCallback {
    func handleConnetionLost(request: RequestBaseProtocol) -> Bool
    func handleNetError(request: RequestBaseProtocol, error: Error)
}

protocol RequestBaseProtocol: AnyObject {
    var path: String { get }
    var httpParams: [String: Any]? { get }
    var timeout: TimeInterval { get }
    var retryOnTimeout: Int { get }
    var afRequest: Request? { get }
    var handlerKey: Int { get set }

    func _perform()
    func removeHandlers()
}

protocol HandlerBlockTypesProtocol {
    associatedtype Target

    typealias ErrorType = API.ErrorType
    typealias SuccessBlock = (Target) -> Void
    typealias ErrorBlock = (ErrorType) -> Bool
}

protocol HandlerBlockProtocol: HandlerBlockTypesProtocol {
    var successBlock: SuccessBlock { get set }
    var errorBlock: ErrorBlock { get set }
}

protocol PerformProtocol: AnyObject {
    func _performIn()
}

extension API {
    static var reportHandler: RequestReportCallback?
    private static var _instanceNum = 0

    class _BaseRequest<Model>: RequestBaseProtocol {
        typealias ErrorModel = API.ErrorType

        var httpParams: [String: Any]? { nil }
        var method: Alamofire.HTTPMethod = .get
        var headers: [String: String]?

        // RequestBaseProtocol
        var path = ""
        var retryOnTimeout = 1
        var id = 0
        var handlerKey = 0
        var isRenewable = true
        var timeout = KNetwork.defaultTimeout
        var isDirect = false
        var isSync = false
        var isShowError = true
        var afRequest: Request?

        var encoding: ParameterEncoding

        required init() {
            encoding = URLEncoding.default
            _instanceNum += 1; DLog(">>>> Instance num: ", _instanceNum)
        }

        deinit {
            DLog(">>>> deinit #", _instanceNum, " - ", path)
            _instanceNum -= 1
        }

        fileprivate var _url: URL {
            guard let url = URL(string: path) else { fatalError("Invalid url string: \(path)") }
            return url
        }

        func handleSuccess(_ model: Model) {
            guard let handlers: _HandlerBlocks<Model> = _removeHandlers(key: handlerKey) else { return }

            // DLog("##### success for: ", handlerKey, " for ", path)
            DispatchQueue.main.async {
                handlers.successBlock(model)
            }
        }

        func handleError(_ error: ErrorType) {
            guard let handlers: _HandlerBlocks<Model> = _removeHandlers(key: handlerKey) else { return }

            let isProcessed: Bool
            if !Thread.isMainThread {
                isProcessed = DispatchQueue.main.sync {
                    handlers.errorBlock(error)
                }
            } else {
                isProcessed = handlers.errorBlock(error)
            }

            if !isProcessed {
                _handleError(error)
            }
        }

        func removeHandlers() {
            guard let handlers: _HandlerBlocks<Model> = _removeHandlers(key: handlerKey) else { return }
            if let observer = handlers.observer {
                // DLog("##### Complete ", path)
                observer.onCompleted()
            }
            // DLog("##### Drop handlers for: ", handlerKey, " of ", path)
        }

        /* fileprivate */ func _performIn() {
            _perform()
        }

        func _perform() {}

        // MARK: Error handling

        fileprivate func _handle(error: Error?) throws {
            guard let urlError = error as? URLError else { return }

            switch urlError {
            case URLError.networkConnectionLost:
                throw ErrorType.connectionLost
            default:
                break
            }
        }

        fileprivate func _handleError(_ error: Error) {
            reportHandler?.handleNetError(request: self, error: error)
        }
    }
}

protocol ResponseHandler {}

private struct _HandlerBlocks<R>: HandlerBlockProtocol, ResponseHandler {
    typealias Target = R

    var successBlock: SuccessBlock
    var errorBlock: ErrorBlock
    var observer: CancelableObserver?

    init(observer: CancelableObserver? = nil, successBlock: @escaping SuccessBlock = { _ in }, errorBlock: @escaping ErrorBlock = { _ in false }) {
        self.successBlock = successBlock
        self.errorBlock = errorBlock
        self.observer = observer
    }
}

extension API {
    private static let _obsGuard = NSLock()
    private static var _handlers: [Int: ResponseHandler] = [:]
    private static var _handlerKey = 0

    fileprivate static func _insert<E>(key: Int = -1, handlers: _HandlerBlocks<E>) -> Int {
        _obsGuard.lock(); defer { _obsGuard.unlock() }

        var k: Int
        if key == -1 {
            k = _handlerKey
            _handlerKey += 1
        } else {
            k = key
        }
        _handlers[k] = handlers
//        DLog("### insert handler: ", k)
        return k
    }

    private static func _getHandlers<E>(key: Int) -> _HandlerBlocks<E>? {
        _obsGuard.lock(); defer { _obsGuard.unlock() }

        return _handlers[key] as? _HandlerBlocks<E>
    }

    private static func _removeHandlers<E>(key: Int) -> _HandlerBlocks<E>? {
        _obsGuard.lock(); defer { _obsGuard.unlock() }

        let blocks = _handlers.removeValue(forKey: key)
//        if let _ = blocks {
//            DLog("### removed handler: ", key)
//        }
        return blocks as? _HandlerBlocks<E>
    }

    // MARK: - Request base class

    class RequestBase<M: Decodable>: _BaseRequest<M>, CombinableType {
        typealias Target = M

        var mainPath = ""
        var fallbackPath = ""

        required init() {
            super.init()

            encoding = JSONEncoding.default
            headers = ["Content-Type": "application/json",
                       "Accept": "application/json",
                       "Accept-Encoding": "gzip"]
            method = httpParams == nil ? .get : .post
        }

        override func _perform() {
            if path.isEmpty { path = mainPath }

            let request = sessionManager
                .request(_url,
                         method: method,
                         parameters: httpParams,
                         encoding: TimeoutParameterEncoding(encoding: encoding, timeout: timeout),
                         headers: HTTPHeaders(headers ?? [:]))

            DLog("Requesting: ", path)

            afRequest = request
            // debugPrint(request)
            request
                .validate()
                .responseDecodable(completionHandler: { (ds: DataResponse<Target, AFError>) in
                    switch ds.result {
                    case let .success(model):
                        self.handleSuccess(model)
                    case let .failure(error):
                        if self.path != self.fallbackPath {
                            self.path = self.fallbackPath
                            self._perform()
                        } else {
                            self.handleError(.netError(error: error))
                        }
                    }
                })
        }
    }
}

// MARK: - Combinable

extension API._BaseRequest: CombineCompatible {}

/// A protocol representing a minimal interface for a model request.
/// Used by the reactive provider extensions.
protocol CombinableType: HandlerBlockTypesProtocol, RequestBaseProtocol, PerformProtocol {
    /// Designated request-making method.
    func perform(onSuccess: @escaping SuccessBlock, onError: @escaping ErrorBlock)
}

protocol CancelableObserver {
    func onCompleted()
}

extension CombinableType {
    func perform(onSuccess: @escaping SuccessBlock = { _ in }, onError: @escaping ErrorBlock = { _ in false }) {
        _perform(observer: nil, onSuccess: onSuccess, onError: onError)
    }

    fileprivate func _perform(observer: CancelableObserver? = nil,
                              onSuccess: @escaping SuccessBlock = { _ in }, onError: @escaping ErrorBlock = { _ in false }) {
        let handlers = _HandlerBlocks<Target>(observer: observer, successBlock: onSuccess, errorBlock: onError)
        handlerKey = API._insert(handlers: handlers)
        _performIn()
    }

    fileprivate func _cmbPerform() -> AnyPublisher<Target, ErrorType> {
//        Deferred {
//            return Future<Target, Error> { promise in
//                self._perform(onSuccess: { result in
//                    promise(.success(result))
//                }, onError: { error in
//                    promise(.failure(error))
//                    return false
//                })
//            }
//        }
//        .eraseToAnyPublisher()
        Subscribers._APIPublisher(request: self).eraseToAnyPublisher()
    }
}

extension Combinable where Base: CombinableType {
    func perform() -> AnyPublisher<Base.Target, Base.ErrorType> {
        base._cmbPerform()
    }
}

// MARK: - Publisher

private extension Subscribers {
    final class _APISubscription<S: Subscriber, R: CombinableType>: Subscription, CancelableObserver where S.Input == R.Target, S.Failure == R.ErrorType {
        private let _request: R
        private var _subscriber: S?

        init(request: R, subscriber: S) {
            _request = request
            _subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {
            _sendRequest()
        }

        func cancel() {
            _subscriber = nil
        }

        func onCompleted() {
            cancel()
        }

        private func _sendRequest() {
            guard let subscriber = _subscriber else { return }

            _request._perform(observer: self, onSuccess: {
                _ = subscriber.receive($0)
                subscriber.receive(completion: .finished)
            }, onError: {
                subscriber.receive(completion: .failure($0))
                return false
            })
        }
    }

    struct _APIPublisher<R: CombinableType>: Publisher {
        typealias Output = R.Target
        typealias Failure = R.ErrorType

        private let _request: R

        init(request: R) {
            _request = request
        }

        func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            let subscription = _APISubscription(request: _request,
                                                subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}
