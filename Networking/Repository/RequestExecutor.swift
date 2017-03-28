//
//  RequestExecutor.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/2/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Alamofire
import ReactiveSwift
import Result

public typealias HTTPResponseProducer = SignalProducer<(URLRequest, HTTPURLResponse, Data), ResponseError>

public protocol RequestExecutorType {
    
    func performRequest(
        method: NetworkingMethod,
        url: URL,
        parameters: [String: Any]?,
        headers: [String: String]?) -> HTTPResponseProducer
    
}

internal final class RequestExecutor: RequestExecutorType {
    
    private let _sessionManager: Alamofire.SessionManager
    
    internal init(sessionManager: Alamofire.SessionManager) {
        _sessionManager = sessionManager
    }
    
    func performRequest(
        method: NetworkingMethod,
        url: URL,
        parameters: [String: Any]? = .none,
        headers: [String: String]? = .none) -> HTTPResponseProducer {
            return _sessionManager
                .request(url,
                         method: method.toHTTPMethod(),
                         parameters: parameters,
                         encoding: URLEncoding.default,
                         headers: headers)
                .validate()
                .response()
    }
    
}

internal func defaultRequestExecutor(networkingConfiguration: NetworkingConfiguration) -> RequestExecutorType {
    let sessionManager = NetworkingSessionManager(networkingConfiguration: networkingConfiguration)
    return RequestExecutor(sessionManager: sessionManager)
}
