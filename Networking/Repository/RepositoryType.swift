//
//  RepositoryType.swift
//  Networking
//
//  Created by Nahuel Gladstein on 28/01/2019.
//  Copyright © 2019 Wolox. All rights reserved.
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
     - headers: request headers.
     - decoder: a closure of type Decoder
     - Returns:
     A SignalProducer where its value is the decoded entity and its
     error a RepositoryError.
     */
    func performRequest<T>(method: NetworkingMethod, path: String, parameters: [String: Any]?,
                           headers: [String: String]?, encodeAs: ParameterEncoding?,
                           decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>
    
    // Same but taking an Array instead of a Dictionary
    func performRequest<T>(method: NetworkingMethod, path: String, parameters: [Any],
                           headers: [String: String]?, decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>
    
    /**
     Performs a request and returns a Signal producer.
     In case the response status code is 202 it will keep polling
     until a 200/201 status code is received or the maximum retries are reached.
     If it succeeds it will decode and return the response,
     if it reaches the maximum retries it will give a timeout error.
     
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
    func performPollingRequest<T>(method: NetworkingMethod, path: String, parameters: [String: Any]?,
                                  headers: [String: String]?, encodeAs: ParameterEncoding?,
                                  decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>
    
    // Same but taking an Array instead of a Dictionary
    func performPollingRequest<T>(method: NetworkingMethod, path: String, parameters: [Any],
                                  headers: [String: String]?, decoder: @escaping Decoder<T>) -> SignalProducer<T, RepositoryError>
    
    /**
     Performs a request and returns a Signal producer.
     As this function does not decode the entity, instead returns the request
     and response information, it can be useful when more data is needed from
     a request, as the status code or a header property, or whatever exceeds
     a received entity.
     
     - Parameters:
     - method: HTTP method for the request.
     - path: path to be appended to domain URL and subdomain URL.
     - headers: request headers.
     - Returns:
     A SignalProducer where its value is a tuple of type
     (URLRequest, HTTPURLResponse, Data) and its error a RepositoryError.
     */
    func performRequest(method: NetworkingMethod, path: String, parameters: [String: Any]?,
                        headers: [String: String]?, encodeAs: ParameterEncoding?) -> SignalProducer<RawDataResponse, RepositoryError>
    
    // Same but taking an Array instead of a Dictionary
    func performRequest(method: NetworkingMethod, path: String, parameters: [Any], headers: [String: String]?) -> SignalProducer<RawDataResponse, RepositoryError>
    
}
