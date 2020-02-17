//
//  RequestProtocols.swift
//
//  Created by Balázs Kilvády on 7/29/17.
//  Copyright © 2017 Balázs Kilvády. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public protocol RequestReportCallback {
    func handleConnetionLost(request: RequestBaseProtocol) -> Bool
    func handleNetError(request: RequestBaseProtocol, error: Error)
}

public protocol RequestBaseProtocol: AnyObject {
    var id: Int { get set }
    var path: String { get }
    var httpParams: [String: Any]? { get }
    var timeout: TimeInterval { get }
    var retryOnTimeout: Int { get }
    var afRequest: Request? { get }
    var handlerKey: Int { get set }

    func _perform()
    func removeHandlers()
}

public protocol HandlerBlockTypesProtocol {
    associatedtype Target

    typealias SuccessBlock = (Target) -> Void
    typealias ErrorBlock = (Error) -> Bool
}

protocol HandlerBlockProtocol: HandlerBlockTypesProtocol {
    var successBlock: SuccessBlock { get set }
    var errorBlock: ErrorBlock { get set }
}

public protocol ModelProtocol {
    associatedtype Result

    init()

    /// Creates model object from JSON responses.
    func process(json: Data) throws -> Result
}

public protocol PerformProtocol: AnyObject {
    func _performIn()
}

extension API {
    public static var reportHandler: RequestReportCallback?
    private static var _instanceNum = 0

    open class _BaseRequest<Model>: RequestBaseProtocol {
        typealias ErrorModel = Error

        public var httpParams: [String: Any]? { return nil }
        public var method: Alamofire.HTTPMethod = .get
        public var headers: [String: String]?

        // RequestBaseProtocol
        public var path = ""
        public var retryOnTimeout = 1
        public var id = 0
        public var handlerKey = 0
        public var isRenewable = true
        public var timeout = KNetwork.defaultTimeout
        public var isDirect = false
        public var isSync = false
        public var isShowError = true
        public var afRequest: Request?

        var encoding: ParameterEncoding

        public required init() {
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

        func handleError(_ error: Error) {
            guard let handlers: _HandlerBlocks<Model> = _removeHandlers(key: handlerKey) else { return }

            let isProcessed = DispatchQueue.main.sync {
                handlers.errorBlock(error)
            }

            if !isProcessed {
                _handleError(error)
            }
        }

        public func removeHandlers() {
            guard let handlers: _HandlerBlocks<Model> = _removeHandlers(key: handlerKey) else { return }
            if let observer = handlers.observer {
                // DLog("##### Complete ", path)
                observer.onCompleted()
            }
            // DLog("##### Drop handlers for: ", handlerKey, " of ", path)
        }

        /* fileprivate */ public func _performIn() {
            _perform()
        }

        public func _perform() {}

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

    public class RequestBase<M: ModelProtocol>: _BaseRequest<M.Result>, RxAbleType {
        public typealias Target = M.Result
        public typealias Model = M
        typealias ResponseParser = (_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: Error?) -> Alamofire.Result<Target>

        var mainPath = ""
        var fallbackPath = ""

        /// Serializes received response into Result<Model>.
        var responseParser: ResponseParser = { request, response, data, error in
            .failure(error!)
        }

        public required init() {
            super.init()

            encoding = JSONEncoding.default
            headers = ["Content-Type": "application/json",
                       "Accept": "application/json",
                       "Accept-Encoding": "gzip"]
            method = httpParams == nil ? .get : .post
        }

        func createModel() -> Model {
            return Model()
        }

        public override func _perform() {
            if path.isEmpty { path = mainPath }

            let request = sessionManager
                .request(_url,
                         method: method,
                         parameters: httpParams,
                         encoding: TimeoutParameterEncoding(encoding: encoding, timeout: timeout),
                         headers: headers)

            DLog("Requesting: ", path, " - ", id)
            responseParser = _responeParser()

            afRequest = request
             debugPrint(request)
            request.validate().response(responseSerializer: _dataResponseSerializer) { response in
                 debugPrint(response)
                switch response.result {
                case let .success(result):
                    self.handleSuccess(result)
                case let .failure(error):
                    if self.path != self.fallbackPath {
                        self.path = self.fallbackPath
                        self._perform()
                    } else {
                        self.handleError(error)
                    }
                }
            }
        }

        private func _responeParser() -> ResponseParser {
            return { [unowned self] request, response, data, error in
                if let error = error { return .failure(error) }
                let data = data ?? Data()
//                let json = (try? JSON(data: data, options: .allowFragments)) ?? JSON.null
//                let response = Response(json: json, request: self, error: error)

                do {
                    let model = self.createModel()
                    let result = try model.process(json: data)
                    return .success(result)
                } catch {
                    return .failure(error)
                }
            }
        }

        private lazy var _dataResponseSerializer = DataResponseSerializer<Target> { [unowned self] urlRequest, response, data, error in
            var result: Alamofire.Result<Target>

//            #if DEBUG
//                if self is GetSession {
//                    sleep(5)
//                    let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
//                    let apiError = Response(code: .errorNet, request: self, error: error)
//                    return .failure(apiError)
//                }
//            #endif

            if let error = error {
                result = .failure(error)
            } else {
                result = self.responseParser(urlRequest, response, data, error)
            }

            return result
        }
    }


    // MARK: - Download base class

    open class DownloadBase<Model>: _BaseRequest<Model>, RxAbleType {
        public typealias Target = Model

        /// Serializes Data into Model.
        public typealias ResponseParser = (_ request: URLRequest?, _ response: HTTPURLResponse?, _ url: URL?, _ error: Error?) -> Alamofire.Result<Model>
        public typealias ToProvider = DownloadRequest.DownloadFileDestination

        /// Serializes received response into Result<Model>
        public var responseParser: ResponseParser = { request, response, url, error in
            .failure(AFError.responseSerializationFailed(reason: .inputFileNil))
        }

        public var toProvider: ToProvider = { url, response in
            (url, [])
        }

        public override func _perform() {
            let download = sessionManager
                .download(_url,
                          method: method,
                          parameters: httpParams,
                          encoding: TimeoutParameterEncoding(encoding: encoding, timeout: timeout),
                          headers: headers,
                          to: toProvider)

            DLog("- Downloading: ", path, " - ", id)

            afRequest = download
            // debugPrint(download)
            download.response(queue: .main, responseSerializer: _downloadResponseSerializer) { response in
                // debugPrint(response)
                switch response.result {
                case let .success(model):
                    self.handleSuccess(model)
                case let .failure(error):
                    self.handleError(error)
                }
            }
        }

        private lazy var _downloadResponseSerializer = DownloadResponseSerializer<Model> { [unowned self] urlRequest, response, url, error in
            var result: Alamofire.Result<Model>

            if let error = error {
                result = .failure(error)
            } else {
                result = self.responseParser(urlRequest, response, url, error)
                if let model = result.value {
                    result = .success(model)
                } else {
                    result = .failure(error ?? NSError(domain: "Network", code: 1, userInfo: nil))
                }
            }

            return result
        }
    }
}

extension API._BaseRequest: ReactiveCompatible {}

/// A protocol representing a minimal interface for a model request.
/// Used by the reactive provider extensions.
public protocol RxAbleType: HandlerBlockTypesProtocol, RequestBaseProtocol, PerformProtocol {
    /// Designated request-making method.
    func perform(onSuccess: @escaping SuccessBlock, onError: @escaping ErrorBlock)
}

public extension Reactive where Base: RxAbleType {
    func perform() -> Observable<Base.Target> {
        return base.rxPerform()
    }
}

protocol CancelableObserver {
    func onCompleted()
}

extension AnyObserver: CancelableObserver {}

extension RxAbleType {
    public func perform(onSuccess: @escaping SuccessBlock = { _ in }, onError: @escaping ErrorBlock = { _ in false }) {
        _perform(observer: nil, onSuccess: onSuccess, onError: onError)
    }

    fileprivate func _perform(observer: CancelableObserver? = nil,
                              onSuccess: @escaping SuccessBlock = { _ in }, onError: @escaping ErrorBlock = { _ in false }) {
        let handlers = _HandlerBlocks<Target>(observer: observer, successBlock: onSuccess, errorBlock: onError)
        handlerKey = API._insert(handlers: handlers)
        _performIn()
    }

    func rxPerform() -> Observable<Target> {
        return Observable.create { observer in
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
