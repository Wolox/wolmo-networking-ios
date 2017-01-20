//
//  DecodedExtension.swift
//  Networking
//
//  Created by Pablo Giorgi on 2/13/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Argo
import enum Result.Result

public extension Decoded {
    
    func toResult() -> Result<T, Argo.DecodeError> {
        switch self {
        case .success(let value):
            return Result(value: value)
        case .failure(let error):
            DecodedErrorHandler.decodedErrorHandler(error)
            return Result(error: error)
        }
    }
    
}

public final class DecodedErrorHandler {
    
    public static var decodedErrorHandler: ((Argo.DecodeError) -> Void) = { _ in }
    
}
