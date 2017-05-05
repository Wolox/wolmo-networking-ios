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
            - decoder: a closure of type Decoder
        - Returns:
            A SignalProducer where its value is the decoded entity and its
            error a RepositoryError.
     */
    func performRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>
    
    /**
        Performs a request and returns a Signal producer.
        This function fails if no user is authenticated.
        In case the response status code is 202 it will keep polling 
        until a 200/201 status code is received, in which case it will
        decode and return the response.
     
        - Parameters:
            - method: HTTP method for the request.
            - path: path to be appended to domain URL and subdomain URL.
            - parameters: request parameters.
            - decoder: a closure of type Decoder
        - Returns:
            A SignalProducer where its value is the decoded entity and its
            error a RepositoryError.
     */
    func performPollingRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>
    
    /**
        Performs a request and returns a Signal producer.
        This function does not fail if user is not authenticated. So, this can
        be useful to perform authentication requests as login or signup.
     
        - Parameters:
            - method: HTTP method for the request.
            - path: path to be appended to domain URL and subdomain URL.
            - parameters: request parameters.
            - decoder: a closure of type Decoder
        - Returns:
            A SignalProducer where its value is the decoded entity and its
            error a RepositoryError.
     */
    func performAuthenticationRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
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
            - parameters: request parameters.
        - Returns:
            A SignalProducer where its value is a tuple of type 
            (URLRequest, HTTPURLResponse, Data) and its error a RepositoryError.
     */
    func performRequest(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?) -> SignalProducer<RawDataResponse, RepositoryError>
    
}

open class AbstractRepository {
    
    fileprivate let _networkingConfiguration: NetworkingConfiguration
    
    fileprivate let _sessionManager: SessionManagerType
    fileprivate let _requestExecutor: RequestExecutorType
    
    public init(networkingConfiguration: NetworkingConfiguration,
                requestExecutor: RequestExecutorType,
                sessionManager: SessionManagerType) {
        _networkingConfiguration = networkingConfiguration
        _requestExecutor = requestExecutor
        _sessionManager = sessionManager
    }
    
    public init(networkingConfiguration: NetworkingConfiguration, sessionManager: SessionManagerType) {
        _networkingConfiguration = networkingConfiguration
        _requestExecutor = defaultRequestExecutor(networkingConfiguration: networkingConfiguration)
        _sessionManager = sessionManager
    }
    
}

extension AbstractRepository: RepositoryType {

    private static let RetryStatusCode = 202
    
    public func performRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        guard _sessionManager.isLoggedIn else { return SignalProducer(error: .unauthenticatedSession) }
        return perform(method: method, path: path, parameters: parameters, headers: authenticationHeaders)
            .flatMap(.concat) { _, _, data in self.deserializeData(data: data, decoder: decoder) }
    }
    
    public func performPollingRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        guard _sessionManager.isLoggedIn else { return SignalProducer(error: .unauthenticatedSession) }
        return perform(method: method, path: path, parameters: parameters, headers: authenticationHeaders)
            .flatMap(.concat) { _, response, data -> SignalProducer<T, RepositoryError> in
                if response.statusCode != AbstractRepository.RetryStatusCode {
                    return self.deserializeData(data: data, decoder: decoder)
                }
                return self.performPollingRequest(method: method, path: path, parameters: parameters, decoder: decoder)
                    .start(on: DelayedScheduler(delay: 1.0))
        }
    }
    
    public func performAuthenticationRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return perform(method: method, path: path, parameters: parameters, headers: .none)
            .flatMap(.concat) { _, _, data in self.deserializeData(data: data, decoder: decoder) }
    }
    
    public func performRequest(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?) -> SignalProducer<RawDataResponse, RepositoryError> {
        guard _sessionManager.isLoggedIn else { return SignalProducer(error: .unauthenticatedSession) }
        return perform(method: method, path: path, parameters: parameters, headers: authenticationHeaders)
    }
    
}

fileprivate extension AbstractRepository {
    
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
        return SignalProducer.attempt {
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
        return SignalProducer(error: .requestError(error))
    }
    
    func perform(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        headers: [String: String]?) -> SignalProducer<RawDataResponse, RepositoryError> {
        guard let url = buildURL(path: path) else { return SignalProducer(error: .invalidURL) }
        
        return _requestExecutor.perform(method: method, url: url, parameters: parameters, headers: headers)
            .flatMapError { self.mapError(error: $0) }
    }
    
}

fileprivate extension JSONSerialization {
    
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
fileprivate final class DelayedScheduler: Scheduler {
    
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
