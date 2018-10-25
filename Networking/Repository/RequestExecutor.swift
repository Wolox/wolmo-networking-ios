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
                         encoding: Encoding(),
                         headers: headers)
                .validate()
                .response()
    }
    
}

struct Encoding: Alamofire.ParameterEncoding {
    
    let url: URLEncoding
    let json: JSONEncoding
    
    init(urlEncoding: URLEncoding = URLEncoding.default, jsonEncoding: JSONEncoding = JSONEncoding.default) {
        self.url = urlEncoding
        self.json = jsonEncoding
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        let method = urlRequest.urlRequest?.httpMethod.flatMap { HTTPMethod(rawValue: $0) } ?? .get
        switch method {
        case .get, .head, .delete:
            return try url.encode(urlRequest, with: parameters)
        default:
            return try json.encode(urlRequest, with: parameters)
        }
    }
    
}

internal func defaultRequestExecutor(networkingConfiguration: NetworkingConfiguration) -> RequestExecutorType {
    let sessionManager = NetworkingSessionManager(networkingConfiguration: networkingConfiguration)
    return RequestExecutor(sessionManager: sessionManager)
}
