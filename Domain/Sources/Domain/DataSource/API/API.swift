//
//  API.swift
//  kil-dev
//
//  Created by Balázs Kilvády on 7/14/17.
//  Copyright © 2017 Balázs Kilvády. All rights reserved.
//

import Foundation
import Alamofire

struct API {
    enum ErrorType: Error {
        case invalidURL
        case disabled
        case invalidJSON
        case processingFailed
        case connectionLost
        case netError(error: Error?)
    }

    struct TimeoutParameterEncoding: ParameterEncoding {
        private let _timeout: TimeInterval
        private let _encoding: ParameterEncoding
        private let _cachePolicy: URLRequest.CachePolicy?

        init(encoding: ParameterEncoding, timeout: TimeInterval, cachePolicy: URLRequest.CachePolicy? = nil) {
            _timeout = timeout
            _encoding = encoding
            _cachePolicy = cachePolicy
        }

        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var request = try _encoding.encode(urlRequest, with: parameters)
            request.timeoutInterval = _timeout
            if let cp = _cachePolicy {
                request.cachePolicy = cp
            }
            return request
        }
    }

    struct TimeoutRetrier: RequestRetrier {
        func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
            if let error = error as? URLError {
                switch error {
                case URLError.timedOut:
                    completion(request.retryCount < 2, 0)
                    return
                default:
                    break
                }
            }
            DLog("# ", request.request?.url?.absoluteURL ?? "nil", " no retry.")
            completion(false, 0)
        }
    }

    static let sessionManager: Alamofire.SessionManager = {
        // Get the default headers.
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        let configuration = URLSessionConfiguration.default
        // Add the headers.
        configuration.httpAdditionalHeaders = headers

        // Create a session manager with the configuration.
        let manager = SessionManager(configuration: configuration)
        guard manager.retrier == nil else { fatalError() }
        manager.retrier = TimeoutRetrier()

        return manager
    }()
}
