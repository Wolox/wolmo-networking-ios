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
        return String(describing: rawValue)
    }
}

/**
    Possible errors when performing a request.
 */
public enum RepositoryError: Error {
    case invalidURL
    case requestError(ResponseError)
    case noNetworkConnection
    case unauthenticatedSession(ResponseError)
    case jsonError(Error)
    case decodeError(Argo.DecodeError)
    case timeout
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
    
    /**
        This function is used to map a RepositoryError.requestError to a RepositoryError.customError
     
        In case the RepositoryError is not .requestError, it just returns the error with no mapping.
        In case it is, this function takes the error (.requestError associated value), and checks if
        any of the parameter keys appear in said error. Once found, it returns a .customError based 
        on the associated value for the error found.
        In case no key is found in the error, it just returns the error with no mapping.
     
        - parameters:
            - errors: a map where its keys are error codes, and its values are custom repository error.
     */
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
        Given a map where its keys are error codes, and its values are custom repository error,
        this function checks if any of these error codes appears in the status code or in the
        body (status code has more priority than body).
        In case none of the provided error codes is found, this function returns .none
     */
    func matchCustomError(errors: [Int: CustomRepositoryErrorType]) -> RepositoryError? {
        if let matchingError = errors[statusCode] {
            return .customError(errorName: matchingError.name, error: matchingError)
        }
        for key in errors.keys {
            if let matchingError = errors[key], error.localizedDescription.contains(String(key)) {
                return .customError(errorName: matchingError.name, error: matchingError)
            }
        }
        return .none
    }
    
}
