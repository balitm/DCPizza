//
//  API.swift
//  kil-dev
//
//  Created by Balázs Kilvády on 7/14/17.
//  Copyright © 2017 Balázs Kilvády. All rights reserved.
//

import Foundation
import Alamofire

public enum API {
    public enum ErrorType: Error {
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
        func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
            if let error = error as? URLError {
                switch error {
                case URLError.timedOut:
                    completion(request.retryCount < 2 ? .retry : .doNotRetry)
                    return
                default:
                    break
                }
            }
            DLog("# ", request.request?.url?.absoluteURL ?? "nil", " no retry.")
            completion(.doNotRetryWithError(error))
        }
    }

    static let sessionManager: Alamofire.Session = {
        // Get the default headers.
        let configuration = URLSessionConfiguration.default
        // Add the headers.
        configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary

        // Create a session manager with the configuration.
        let i = Interceptor(adapters: [], retriers: [TimeoutRetrier()])
        let manager = Session(configuration: configuration, interceptor: i)

        return manager
    }()
}
