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
    func perform(method: NetworkingMethod, url: URL, parameters: [String: Any]?, headers: [String: String]?, encodeAs: ParameterEncoding?) -> HTTPResponseProducer
}

/**
    Default implementation of RequestExecutorType which uses Alamofire
    to perform a HTTP request.
    This function performs the request, validates the status code is valid,
    otherwise fails, and returns the response.
 */
internal final class RequestExecutor: RequestExecutorType {
    private let _sessionManager: Alamofire.SessionManager
    private let _encoding: Encoding
    
    internal init(sessionManager: Alamofire.SessionManager, encoding: Encoding) {
        _sessionManager = sessionManager
        _encoding = encoding
    }
    
    func perform(method: NetworkingMethod, url: URL, parameters: [String: Any]? = .none,
                 headers: [String: String]? = .none, encodeAs: ParameterEncoding? = .none) -> HTTPResponseProducer {
        return _sessionManager
                .request(url, method: method.toHTTPMethod(), parameters: parameters, encoding: encodeAs ?? _encoding, headers: headers)
                .validate()
                .response()
    }
    
}

public struct Encoding: Alamofire.ParameterEncoding {
    let url: URLEncoding
    let json: JSONEncoding
    let encodeAsURL: [HTTPMethod]
    
    init(encodeAsURL: [HTTPMethod], urlEncoding: URLEncoding = .default, jsonEncoding: JSONEncoding = .default) {
        self.url = urlEncoding
        self.json = jsonEncoding
        self.encodeAsURL = encodeAsURL
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        let method = urlRequest.urlRequest?.httpMethod.flatMap { HTTPMethod(rawValue: $0) } ?? .get
        
        if encodeAsURL.contains(method) {
            return try url.encode(urlRequest, with: parameters)
        } else {
            return try json.encode(urlRequest, with: parameters)
        }
    }
    
}

public struct ArrayEncoding: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters = parameters, let array = parameters[AbstractRepository.ArrayEncodingParametersKey] else {
            return urlRequest
        }
            
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
            
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: array)
        
        return urlRequest
    }
    
}


internal func defaultRequestExecutor(configuration: NetworkingConfiguration) -> RequestExecutorType {
    let sessionManager = NetworkingSessionManager(configuration: configuration)
    return RequestExecutor(sessionManager: sessionManager, encoding: Encoding(encodeAsURL: configuration.encodeAsURL))
}
