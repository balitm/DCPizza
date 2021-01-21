//
//  RequestProtocols.swift
//  Domain
//
//  Created by Balázs Kilvády on 7/29/17.
//  Copyright © 2017 Balázs Kilvády. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import RxSwift

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

    typealias SuccessBlock = (Target) -> Void
    typealias ErrorBlock = (Error) -> Bool
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
        typealias ErrorModel = Error

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
        var afRequest: Request?

        var encoding: ParameterEncoding

        required init() {
            encoding = URLEncoding.default
            _instanceNum += 1
            // DLog(">>>> Instance num: ", _instanceNum)
        }

        deinit {
            // DLog(">>>> deinit #" _instanceNum, " - ", path)
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

        func handleError(_ error: Error) {
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
        // if let _ = blocks {
        //     DLog("### removed handler: ", key)
        // }
        return blocks as? _HandlerBlocks<E>
    }

    // MARK: - Request base class

    class RequestBase<M: Decodable>: _BaseRequest<M>, RxAbleType {
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

            // DLog("Requesting: ", path)

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
                            self.handleError(error)
                        }
                    }
                })
        }
    }
}

// MARK: - Image downloader

extension API {
    class ImageDownloader: _BaseRequest<Image>, RxAbleType {
        typealias Target = Image

        init(path: String) {
            super.init()
            self.path = path
        }

        required init() {
            super.init()
        }

        override func _perform() {
            let downloader = AlamofireImage.ImageDownloader()

            // DLog("- Downloading: ", path, " - ", id)

            let res = downloader.download(URLRequest(url: _url), completion: { [weak self] response in
                guard let self = self else { return }

                // print(response.request)
                // print(response.response)

                switch response.result {
                case let .success(image):
                    self.handleSuccess(image)
                case let .failure(error):
                    self.handleError(error)
                }

            })
            afRequest = res?.request
        }
    }
}

// MARK: - Rx

extension API._BaseRequest: ReactiveCompatible {}

/// A protocol representing a minimal interface for a model request.
/// Used by the reactive provider extensions.
protocol RxAbleType: HandlerBlockTypesProtocol, RequestBaseProtocol, PerformProtocol {
    /// Designated request-making method.
    func perform(onSuccess: @escaping SuccessBlock, onError: @escaping ErrorBlock)
}

extension Reactive where Base: RxAbleType {
    func perform() -> Observable<Base.Target> {
        base.rxPerform()
    }
}

protocol CancelableObserver {
    func onCompleted()
}

extension AnyObserver: CancelableObserver {}

extension RxAbleType {
    func perform(onSuccess: @escaping SuccessBlock = { _ in }, onError: @escaping ErrorBlock = { _ in false }) {
        _perform(observer: nil, onSuccess: onSuccess, onError: onError)
    }

    fileprivate func _perform(observer: CancelableObserver? = nil,
                              onSuccess: @escaping SuccessBlock = { _ in }, onError: @escaping ErrorBlock = { _ in false })
    {
        let handlers = _HandlerBlocks<Target>(observer: observer, successBlock: onSuccess, errorBlock: onError)
        handlerKey = API._insert(handlers: handlers)
        _performIn()
    }

    func rxPerform() -> Observable<Target> {
        Observable.create { observer in
            self._perform(observer: observer, onSuccess: { result in
                observer.onNext(result)
                observer.onCompleted()
            }, onError: { error in
                observer.onError(error)
                return false
            })
            return Disposables.create { // [weak self] in
                self.afRequest?.cancel()
            }
        }
    }
}
