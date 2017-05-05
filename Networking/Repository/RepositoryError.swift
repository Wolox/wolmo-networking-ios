//
//  RepositoryError.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/7/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Argo
import ReactiveSwift

/**
    Protocol intended to be implemented to model custom errors related
    with the particular model of the developed application.
 */
public protocol CustomRepositoryErrorType: Error {
    
    /**
        Message to describe the error.
     */
    var name: String { get }
}

public extension CustomRepositoryErrorType where Self: RawRepresentable {
    
    var name: String {
        return String(describing: self.rawValue)
    }
    
}

/**
    Possible errors when performing a request.
 */
public enum RepositoryError: Error {
    case invalidURL
    case requestError(ResponseError)
    case noNetworkConnection
    case unauthenticatedSession
    case jsonError(Error)
    case decodeError(Argo.DecodeError)
    case customError(errorName: String, error: CustomRepositoryErrorType)
}

/**
    Extension to be used in repositories after performing a request 
    in which a generic request or response error can be mapped with
    a certain code to a custom repository error.
    This mapping is done by searching in the response body for a code which will be
    mapped to a particular custom repository error.
 */
public extension SignalProducer where Error == RepositoryError {
    
    func mapCustomError(errors: [Int: CustomRepositoryErrorType]) -> SignalProducer<Value, RepositoryError> {
        return mapError {
            switch $0 {
            case .requestError(let error): return error.matchCustomError(errors: errors) ?? $0
            default: return $0
            }
        }
    }
    
}

private extension ResponseError {
    
    /**
        Given a map of error code to custom repository error, it checks first in the
        status code if it matches any of them. In case it doesn't, it check in the response
        body if any of them appears there.
        In case there is no match, this function returns .none
     */
    func matchCustomError(errors: [Int: CustomRepositoryErrorType]) -> RepositoryError? {
        if let matchingError = errors[statusCode] {
            return RepositoryError.customError(errorName: matchingError.name, error: matchingError)
        }
        for key in errors.keys {
            if let matchingError = errors[key], error.localizedDescription.contains(String(key)) {
                return RepositoryError.customError(errorName: matchingError.name, error: matchingError)
            }
        }
        return .none
    }
    
}
