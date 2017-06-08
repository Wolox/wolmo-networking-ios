//
//  DecodedExtension.swift
//  Networking
//
//  Created by Pablo Giorgi on 2/13/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Argo
import enum Result.Result

/**
    Decoded extension wrapping self as a Result instance.
    It provides a handler which can be set by the static property
    `decodedErrorHandler` in `DecodedErrorHandler`, which will be executed
    each time a decoding fails.
 */
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

public extension Decodable where Self: RawRepresentable, Self.RawValue: Decodable {
    
    static func decode(_ json: JSON) -> Decoded<Self> {
        switch json {
        case let .string(name) where name is Self.RawValue: return castValueToEnum(name)
        case let .bool(value) where value is Self.RawValue: return castValueToEnum(value)
        case let .number(value) where value is Self.RawValue: return castValueToEnum(value)
        default: return .failure(Argo.DecodeError.custom("Invalid \(Self.self) enum value"))
        }
    }
    
    private static func castValueToEnum(_ value: Any) -> Decoded<Self> {
        return .fromOptional(Self(rawValue: value as! Self.RawValue)) // swiftlint:disable:this force_cast
    }
    
}

public final class DecodedErrorHandler {
    
    public static var decodedErrorHandler: ((Argo.DecodeError) -> Void) = { _ in }
    
}
