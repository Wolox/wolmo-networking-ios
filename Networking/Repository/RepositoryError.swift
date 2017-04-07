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
        return self.mapError { $0.mapCustomError(errors: errors) }
    }
    
}

private extension RepositoryError {
    
    func mapCustomError(errors: [Int: CustomRepositoryErrorType]) -> RepositoryError {
        switch self {
        case .requestError(let error):
            // TODO: Search error in status code instead of in the error body when API applies this refactor.
            if let failureReason = error.error.userInfo[NSLocalizedFailureReasonErrorKey] as? String {
                for key in errors.keys {
                    if failureReason.contains(String(key)) {
                        let error = errors[key]!
                        return RepositoryError.customError(errorName: error.name, error: error)
                    }
                }
            }
        default: break
        }
        return self
    }
    
}
