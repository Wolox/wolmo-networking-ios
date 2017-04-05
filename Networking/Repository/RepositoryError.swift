//
//  RepositoryError.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/7/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Argo

// This is to be implemented by the final user to model custom errors related with the project itself.
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

public enum RepositoryError: Error {
    case invalidURL
    case requestError(ResponseError)
    case noNetworkConnection
    case unauthenticatedSession
    case jsonError(Error)
    case decodeError(Argo.DecodeError)
    case customError(errorName: String, error: CustomRepositoryErrorType)
}

public extension RepositoryError {
    
    // This looks for the error code in the error string received in the response
    // This is useful to map a requestError specified by API to a specific customError
    func mapCustomError(errors: Dictionary<Int, CustomRepositoryErrorType>) -> RepositoryError {
        switch self {
        case .requestError(let error):
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
