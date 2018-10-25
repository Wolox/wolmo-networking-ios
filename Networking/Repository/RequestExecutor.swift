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

/**
    Typealias to wrap a Signal producer which value is a tuple
    with (URLRequest, HTTPURLResponse, Data) to return the request
    and response data in case of success.
    Its error type is ResponseError, which models an error get in
    a HTTP request.
 */
public typealias HTTPResponseProducer = SignalProducer<(URLRequest, HTTPURLResponse, Data), ResponseError>

/**
    Protocol used by AbstractRepository which declares a function
    which given a HTTP method, an URL, request parameters and 
    request headers returns a response of type HTTPResponseProducer.
 */
public protocol RequestExecutorType {
    
    func perform(
        method: NetworkingMethod,
        url: URL,
        parameters: [String: Any]?,
        headers: [String: String]?) -> HTTPResponseProducer
    
}

/**
    Default implementation of RequestExecutorType which uses Alamofire
    to perform a HTTP request.
    This function performs the request, validates the status code is valid,
    otherwise fails, and returns the response.
 */
internal final class RequestExecutor: RequestExecutorType {
    
    private let _sessionManager: Alamofire.SessionManager
    
    internal init(sessionManager: Alamofire.SessionManager) {
        _sessionManager = sessionManager
    }
    
    func perform(
        method: NetworkingMethod,
        url: URL,
        parameters: [String: Any]? = .none,
        headers: [String: String]? = .none) -> HTTPResponseProducer {
            return _sessionManager
                .request(url,
                         method: method.toHTTPMethod(),
                         parameters: parameters,
                         encoding: JSONEncoding.default,
                         headers: headers)
                .validate()
                .response()
    }
    
}

internal func defaultRequestExecutor(networkingConfiguration: NetworkingConfiguration) -> RequestExecutorType {
    let sessionManager = NetworkingSessionManager(networkingConfiguration: networkingConfiguration)
    return RequestExecutor(sessionManager: sessionManager)
}
