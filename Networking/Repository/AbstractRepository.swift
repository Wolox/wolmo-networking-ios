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

open class AbstractRepository {
    private let _configuration: NetworkingConfiguration
    private let _executor: RequestExecutorType
    private let _defaultHeaders: [String: String]?
    
    private var maximumRetries: Int {
        return _configuration.maximumPollingRetries ?? _configuration.defaultPollingRetries
    }
    
    public init(configuration: NetworkingConfiguration, executor: RequestExecutorType, defaultHeaders: [String: String]? = .none) {
        _configuration = configuration
        _executor = executor
        _defaultHeaders = defaultHeaders
    }
    
    public convenience init(configuration: NetworkingConfiguration, defaultHeaders: [String: String]? = .none) {
        self.init(configuration: configuration,
                  executor: defaultRequestExecutor(configuration: configuration),
                  defaultHeaders: defaultHeaders)
    }
    
}

extension AbstractRepository: RepositoryType {
    private static let RetryStatusCode = 202
    internal static let ArrayEncodingParametersKey = "EncodedArray"
    
    public func performRequest<T>(method: NetworkingMethod, path: String, parameters: [String: Any]? = .none,
                                  headers: [String: String]? = .none, encodeAs: ParameterEncoding? = .none,
                                  decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return perform(method: method, path: path, parameters: parameters, headers: headers, encodeAs: encodeAs)
            .flatMap(.concat) { (request: URLRequest, response: HTTPURLResponse, data: Data) -> SignalProducer<T, RepositoryError> in
            self._configuration.interceptor?.intercept(request: request, response: response, data: data)
                return self.deserializeData(data: data, decoder: decoder)
            }
    }
    
    public func performRequest<T>(method: NetworkingMethod, path: String, parameters: [Any],
                                  headers: [String: String]? = .none, decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return performRequest(method: method, path: path, parameters: parameters.asParameters(), headers: headers, encodeAs: ArrayEncoding(), decoder: decoder)
    }
    
    public func performPollingRequest<T>(method: NetworkingMethod, path: String, parameters: [String: Any]? = .none,
                                         headers: [String: String]? = .none, encodeAs: ParameterEncoding? = .none,
                                         decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return tryPollingRequest(method: method, path: path, tryNumber: 0, parameters: parameters, headers: headers, encodeAs: encodeAs, decoder: decoder)
    }
    
    public func performPollingRequest<T>(method: NetworkingMethod, path: String, parameters: [Any],
                                         headers: [String: String]? = .none, decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return performPollingRequest(method: method, path: path, parameters: parameters.asParameters(), headers: headers, encodeAs: ArrayEncoding(), decoder: decoder)
    }
    
    public func performRequest(method: NetworkingMethod, path: String, parameters: [String: Any]? = .none,
                               headers: [String: String]? = .none, encodeAs: ParameterEncoding? = .none) -> SignalProducer<RawDataResponse, RepositoryError> {
        return perform(method: method, path: path, parameters: parameters, headers: headers, encodeAs: encodeAs)
    }
    
    public func performRequest(method: NetworkingMethod, path: String, parameters: [Any],
                               headers: [String: String]? = .none) -> SignalProducer<RawDataResponse, RepositoryError> {
        return performRequest(method: method, path: path, parameters: parameters.asParameters(), headers: headers, encodeAs: ArrayEncoding())
    }
    
}

private extension AbstractRepository {
    private static let NoNetworkConnectionStatusCode = 0
    private static let UnauthorizedStatusCode = 401
    
    func buildURL(path: String) -> URL? {
        return _configuration.baseURL.appendingPathComponent(path)
    }
    
    func deserializeData<T>(data: Data, decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return SignalProducer {
            JSONSerialization.privateJsonObject(with: data)
                .mapError { .jsonError($0) }
                .flatMap { decoder($0).mapError { .decodeError($0) } }
        }
    }
    
    func mapError<T>(error: ResponseError) -> SignalProducer<T, RepositoryError> {
        switch error.statusCode {
        case AbstractRepository.NoNetworkConnectionStatusCode:
            return SignalProducer(error: .noNetworkConnection)
        case AbstractRepository.UnauthorizedStatusCode:
            return SignalProducer(error: .unauthenticatedSession(error))
        case NSURLErrorTimedOut:
            return SignalProducer(error: .timeout)
        default:
            return SignalProducer(error: .requestError(error))
        }
        
    }
    
    func tryPollingRequest<T>(method: NetworkingMethod, path: String, tryNumber: Int = 0, parameters: [String: Any]? = .none,
                              headers: [String: String]? = .none, encodeAs: ParameterEncoding? = .none, decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError> {
        return perform(method: method, path: path, parameters: parameters, headers: headers, encodeAs: encodeAs)
            .flatMap(.concat) { _, response, data -> SignalProducer<T, RepositoryError> in
                if response.statusCode != AbstractRepository.RetryStatusCode {
                    return self.deserializeData(data: data, decoder: decoder)
                }
                
                if tryNumber > self.maximumRetries {
                    return SignalProducer(error: .timeout)
                }
                
                let newTryNumber = tryNumber + 1
                return self.tryPollingRequest(method: method, path: path, tryNumber: newTryNumber, parameters: parameters,
                                              headers: headers, encodeAs: encodeAs, decoder: decoder)
                    .start(on: DelayedScheduler(delay: self._configuration.secondsBetweenPolls))
        }
    }
    
    func perform(method: NetworkingMethod, path: String, parameters: [String: Any]? = .none,
                 headers: [String: String]? = .none, encodeAs: ParameterEncoding? = .none) -> SignalProducer<RawDataResponse, RepositoryError> {
        
        guard let url = buildURL(path: path) else { return SignalProducer(error: .invalidURL) }
        
        let newHeaders = (headers ?? [:]).appending(contentsOf: _defaultHeaders)
        
        return _executor.perform(method: method, url: url, parameters: parameters, headers: newHeaders, encodeAs: encodeAs)
            .flatMapError { [unowned self] in
                self.mapError(error: $0)
            }
    }
    
}

private extension JSONSerialization {
    
    // Calling this function without private prefix causes an infinite loop.
    // I couldn't figure out why it was not happening before.
    // To be fixed in code review.
    static func privateJsonObject(with data: Data, options: JSONSerialization.ReadingOptions = .allowFragments) -> JSONResult {
        guard data.count > 0 else { return JSONResult(value: NSDictionary()) }
        
        let decode: () throws -> AnyObject = {
            return try JSONSerialization.jsonObject(with: data, options: options) as AnyObject
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
    func appending(contentsOf dictionary: [Key: Value]?) -> [Key: Value] {
        guard let dictionary = dictionary else {
            return self
        }
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

/**
    Extension to make an encodable dictionary out of an array
 */
private extension Array {
    func asParameters() -> [String: Any] {
        return [AbstractRepository.ArrayEncodingParametersKey: self]
    }
}
