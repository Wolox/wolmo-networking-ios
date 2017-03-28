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

public typealias Decoder<T> = (AnyObject) -> Result<T, Argo.DecodeError>

public protocol RepositoryType {
    
    func performRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>
    
    func performPollingRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>
    
    func performAuthenticationRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>

    func performRequest(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?) -> SignalProducer<(URLRequest, HTTPURLResponse, Data), RepositoryError>
    
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

    public func performRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        guard _sessionManager.isLoggedIn else { return SignalProducer(error: .unauthenticatedSession) }
        
        return performRequestExecution(
            method: method,
            path: path,
            parameters: parameters,
            headers: authenticationHeaders,
            decoder: decoder)
    }
    
    public func performPollingRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        guard _sessionManager.isLoggedIn else { return SignalProducer(error: .unauthenticatedSession) }
        
        return performPollingRequestExecution(
            method: method,
            path: path,
            parameters: parameters,
            headers: authenticationHeaders,
            decoder: decoder)
    }
    
    public func performAuthenticationRequest<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return performRequestExecution(
            method: method,
            path: path,
            parameters: parameters,
            headers: .none,
            decoder: decoder)
    }
    
    public func performRequest(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?) -> SignalProducer<(URLRequest, HTTPURLResponse, Data), RepositoryError> {
        guard _sessionManager.isLoggedIn else { return SignalProducer(error: .unauthenticatedSession) }
        
        let URL = buildURL(path: path)
        guard URL != .none else { return SignalProducer(error: .invalidURL) }
        
        return _requestExecutor.performRequest(
            method: method,
            url: URL!,
            parameters: parameters,
            headers: authenticationHeaders
        ).flatMapError { self.mapError(error: $0) }
    }
    
}

fileprivate extension AbstractRepository {
    
    private static let SessionTokenHeader = "Authorization"
    
    func buildURL(path: String) -> URL? {
        let fullURL = _networkingConfiguration.baseURL + "/" + path
        return URL(string: fullURL)
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
        if let connectionError = error.error.userInfo[NSLocalizedDescriptionKey] as? String {
            if connectionError.contains("Internet connection") {
                return SignalProducer(error: .noNetworkConnection)
            }
        }
        if let failureReason = error.error.userInfo[NSLocalizedFailureReasonErrorKey] as? String {
            if _sessionManager.isLoggedIn && failureReason.contains(String(401)) {
                _sessionManager.expire()
                return SignalProducer(error: .unauthenticatedSession)
            }
        }
        return SignalProducer(error: .requestError(error))
    }
    
    func performRequestExecution<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        headers: [String: String]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        let URL = buildURL(path: path)
        guard URL != .none else { return SignalProducer(error: .invalidURL) }
        
        return _requestExecutor.performRequest(method: method, url: URL!, parameters: parameters, headers: headers)
            .flatMapError { self.mapError(error: $0) }
            .flatMap(.concat) { _, _, data in self.deserializeData(data: data, decoder: decoder) }
    }
    
    func performPollingRequestExecution<T>(
        method: NetworkingMethod,
        path: String,
        parameters: [String: Any]?,
        headers: [String: String]?,
        decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        let URL = buildURL(path: path)
        guard URL != .none else { return SignalProducer(error: .invalidURL) }
        
        return _requestExecutor.performRequest(method: method, url: URL!, parameters: parameters, headers: headers)
            .flatMapError { self.mapError(error: $0) }
            .flatMap(.concat) { _, response, data -> SignalProducer<T, RepositoryError> in
                if response.statusCode != 202 {
                    return self.deserializeData(data: data, decoder: decoder)
                }
                return self.performPollingRequestExecution(method: method,
                    path: path,
                    parameters: parameters,
                    headers: headers,
                    decoder: decoder
                ).start(on: DelayedScheduler(delay: 1.0))
            }
        }
}

fileprivate extension JSONSerialization {
    
    // Calling this function without private prefix causes an infinite loop.
    // I couldn't figure out why it was not happening before.
    // To be fixed in code review.
    static func privateJsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions = .allowFragments) -> JSONResult {
        guard data.count > 0 else { return JSONResult(value: NSDictionary()) }
        
        let decode: () throws -> AnyObject = {
            return try JSONSerialization.jsonObject(with: data, options: opt) as AnyObject
        }
        return JSONResult(attempt: decode)
    }
    
}

fileprivate final class DelayedScheduler: Scheduler {
    
    private let _queueScheduler = QueueScheduler()
    private let _futureDate: Date
    
    init(futureDate: Date) {
        _futureDate = futureDate
    }
    
    convenience init(delay: TimeInterval) {
        self.init(futureDate: Date().addingTimeInterval(delay))
    }
    
    func schedule(_ action: @escaping () -> ()) -> Disposable? {
        return _queueScheduler.schedule(after: _futureDate, action: action)
    }
    
}
