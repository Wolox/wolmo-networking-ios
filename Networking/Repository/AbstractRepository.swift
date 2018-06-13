//
//  AbstractRepository.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/2/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import ReactiveSwift
import Alamofire
import Argo
import enum Result.Result

/**
    Typealias to model a closure used to decode a fetched entity.
    Its type matches the entity type.
    Its error is a DecodeError, in case the response does not match what the model expected.
 */
public typealias Decoder<T> = (AnyObject) -> Result<T, Argo.DecodeError>

/**
    Typealias to model a tuple of request, response and data.
    Used as return type of functions in which there is no expected type, instead the
    complete request, response and data of the operation is provided.
 */
public typealias RawDataResponse = (URLRequest, HTTPURLResponse, Data)

/**
    Protocol which declares the different ways of performing a request.
    Implemented by AbstractRepository.
 */
public protocol RepositoryType {
    
    /**
        Performs a request and returns a Signal producer.
        This function fails if no user is authenticated.
     
        - Parameters:
            - method: HTTP method for the request.
            - path: path to be appended to domain URL and subdomain URL.
            - parameters: request parameters.
            - headers: request headers. Authentication headers 
            are automatically injected. No need to be provided.
            - decoder: a closure of type Decoder
        - Returns:
            A SignalProducer where its value is the decoded entity and its
            error a RepositoryError.
     */
    func performRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        headers: [String: String]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>
    
    /**
        Performs a request and returns a Signal producer.
        This function fails if no user is authenticated.
        In case the response status code is 202 it will keep polling
        until a 200/201 status code is received or the maximum retries are reached.
        If it succeeds it will decode and return the response,
        if it reaches the maximum retries it will give a timeout error.
     
        - Parameters:
            - method: HTTP method for the request.
            - path: path to be appended to domain URL and subdomain URL.
            - parameters: request parameters.
            - headers: request headers. Authentication headers 
            are automatically injected. No need to be provided.
            - decoder: a closure of type Decoder
        - Returns:
            A SignalProducer where its value is the decoded entity and its
            error a RepositoryError.
     */
    func performPollingRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        headers: [String: String]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>
    
    /**
        Performs a request and returns a Signal producer.
        This function does not fail if user is not authenticated. So, this is 
        useful to perform authentication requests as login or signup.
     
        - Parameters:
            - method: HTTP method for the request.
            - path: path to be appended to domain URL and subdomain URL.
            - parameters: request parameters.
            - headers: request headers.
            - decoder: a closure of type Decoder
        - Returns:
            A SignalProducer where its value is the decoded entity and its
            error a RepositoryError.
     */
    func performAuthenticationRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        headers: [String: String]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>
    
    /**
        Performs a request and returns a Signal producer.
        This function fails if no user is authenticated.
        As this function does not decode the entity, instead returns the request
        and response information, it can be useful when more data is needed from
        a request, as the status code or a header property, or whatever exceeds
        a received entity.
     
        - Parameters:
            - method: HTTP method for the request.
            - path: path to be appended to domain URL and subdomain URL.
            - headers: request headers. Authentication headers 
            are automatically injected. No need to be provided.
            - headers: request headers.
        - Returns:
            A SignalProducer where its value is a tuple of type
            (URLRequest, HTTPURLResponse, Data) and its error a RepositoryError.
     */
    func performRequest(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        headers: [String: String]?) -> SignalProducer<RawDataResponse, RepositoryError>
    
}

open class AbstractRepository {
    
    fileprivate let _networkingConfiguration: NetworkingConfiguration
    
    fileprivate let _sessionManager: SessionManagerType
    fileprivate let _requestExecutor: RequestExecutorType
    
    fileprivate let _defaultHeaders: [String: String]?
    
    public init(networkingConfiguration: NetworkingConfiguration,
                requestExecutor: RequestExecutorType,
                sessionManager: SessionManagerType,
                defaultHeaders: [String: String]? = .none) {
        _networkingConfiguration = networkingConfiguration
        _requestExecutor = requestExecutor
        _sessionManager = sessionManager
        _defaultHeaders = defaultHeaders
    }
    
    public convenience init(networkingConfiguration: NetworkingConfiguration,
                            sessionManager: SessionManagerType,
                            defaultHeaders: [String: String]? = .none) {
        self.init(networkingConfiguration: networkingConfiguration,
                  requestExecutor: defaultRequestExecutor(networkingConfiguration: networkingConfiguration),
                  sessionManager: sessionManager,
                  defaultHeaders: defaultHeaders)
    }
    
}

extension AbstractRepository: RepositoryType {
    
    private static let RetryStatusCode = 202
    
    public func performRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]? = .none,
        headers: [String: String]? = .none,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return perform(method: method, path: path, parameters: parameters, headers: headers, requiresSession: true)
            .flatMap(.concat) { _, _, data in self.deserializeData(data: data, decoder: decoder) }
    }
    
    public func performPollingRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]? = .none,
        headers: [String: String]? = .none,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return tryPollingRequest(method: method, path: path, tryNumber: 0, decoder: decoder)
    }
    
    public func performAuthenticationRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]? = .none,
        headers: [String: String]? = .none,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return perform(method: method, path: path, parameters: parameters, headers: headers, requiresSession: false)
            .flatMap(.concat) { _, _, data in self.deserializeData(data: data, decoder: decoder) }
    }
    
    public func performRequest(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]? = .none,
        headers: [String: String]? = .none) -> SignalProducer<RawDataResponse, RepositoryError> {
        return perform(method: method, path: path, parameters: parameters, headers: headers, requiresSession: true)
    }
    
}

private extension AbstractRepository {
    
    private static let SessionTokenHeader = "Authorization"
    private static let NoNetworkConnectionStatusCode = 0
    private static let UnauthorizedStatusCode = 401
    
    func buildURL(path: String) -> URL? {
        return _networkingConfiguration.baseURL.appendingPathComponent(path)
    }
    
    var authenticationHeaders: [String: String] {
        return [AbstractRepository.SessionTokenHeader: _sessionManager.sessionToken!]
    }
    
    func deserializeData<T>(data: Data, decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return SignalProducer {
            JSONSerialization.privateJsonObject(with: data)
                .mapError { .jsonError($0) }
                .flatMap { decoder($0).mapError { .decodeError($0) } }
        }
    }
    
    func mapError<T>(error: ResponseError) -> SignalProducer<T, RepositoryError> {
        if error.statusCode == AbstractRepository.NoNetworkConnectionStatusCode {
            return SignalProducer(error: .noNetworkConnection)
        }
        if error.statusCode == AbstractRepository.UnauthorizedStatusCode {
            if _sessionManager.isLoggedIn {
                _sessionManager.expire()
            }
            return SignalProducer(error: .unauthenticatedSession)
        }
        if error.statusCode == NSURLErrorTimedOut {
            return SignalProducer(error: .timeout)
        }
        
        return SignalProducer(error: .requestError(error))
    }
    
    func tryPollingRequest<T>(
        method: NetworkingMethod,
        path: String,
        tryNumber: Int = 0,
        parameters: [String: Any]? = .none,
        headers: [String: String]? = .none,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return perform(method: method, path: path, parameters: parameters, headers: headers, requiresSession: true)
            .flatMap(.concat) { _, response, data -> SignalProducer<T, RepositoryError> in
                if response.statusCode != AbstractRepository.RetryStatusCode {
                    return self.deserializeData(data: data, decoder: decoder)
                }
                
                let maximumRetries = self._networkingConfiguration.maximumPollingRetries ?? self._networkingConfiguration.defaultPollingRetries
                
                if tryNumber > maximumRetries {
                    return SignalProducer(error: .timeout)
                }
                let newTryNumber = tryNumber + 1
                return self.tryPollingRequest(method: method,
                                                  path: path,
                                                  tryNumber: newTryNumber,
                                                  parameters: parameters,
                                                  headers: headers,
                                                  decoder: decoder)
                    .start(on: DelayedScheduler(delay: self._networkingConfiguration.secondsBetweenPolls))
        }
    }
    
    func perform(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]? = .none,
        headers: [String: String]? = .none,
        requiresSession: Bool) -> SignalProducer<RawDataResponse, RepositoryError> {
        guard let url = buildURL(path: path) else { return SignalProducer(error: .invalidURL) }
        
        var headers = headers
        if requiresSession {
            guard _sessionManager.isLoggedIn else { return SignalProducer(error: .unauthenticatedSession) }
            headers = (headers ?? [:]).appending(contentsOf: authenticationHeaders)
        }
        if let defaultHeaders = _defaultHeaders {
            headers = (headers ?? [:]).appending(contentsOf: defaultHeaders)
        }
        
        return _requestExecutor.perform(method: method, url: url, parameters: parameters, headers: headers)
            .flatMapError { self.mapError(error: $0) }
    }
    
}

private extension JSONSerialization {
    
    // Calling this function without private prefix causes an infinite loop.
    // I couldn't figure out why it was not happening before.
    // To be fixed in code review.
    static func privateJsonObject(with data: Data,
                                  options opt: JSONSerialization.ReadingOptions = .allowFragments) -> JSONResult {
        guard data.count > 0 else { return JSONResult(value: NSDictionary()) }
        
        let decode: () throws -> AnyObject = {
            return try JSONSerialization.jsonObject(with: data, options: opt) as AnyObject
        }
        return JSONResult(attempt: decode)
    }
    
}

/**
    This class is used in the polling request executor to apply a delay
    between the response and the next request performed.
 */
private final class DelayedScheduler: Scheduler {
    
    private let _queueScheduler = QueueScheduler()
    private let _futureDate: Date
    
    init(futureDate: Date) {
        _futureDate = futureDate
    }
    
    convenience init(delay: TimeInterval) {
        self.init(futureDate: Date().addingTimeInterval(delay))
    }
    
    func schedule(_ action: @escaping () -> Void) -> Disposable? {
        return _queueScheduler.schedule(after: _futureDate, action: action)
    }
    
}

/**
    Extension to append contents of a dictionary to a given dictionary.
    Used to append authentication headers to provided headers.
 */
private extension Dictionary {
    
    func appending(contentsOf dictionary: [Key: Value]) -> [Key: Value] {
        var result = self
        result.append(contentsOf: dictionary)
        return result
    }
    
    mutating func append(contentsOf dictionary: [Key: Value]) {
        for (key, value) in dictionary {
            updateValue(value, forKey: key)
        }
    }
    
}
