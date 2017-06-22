//
//  DecodableExtension.swift
//  Networking
//
//  Created by Nahuel Gladstein on 6/13/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Argo

public extension Argo.Decodable where Self: RawRepresentable, Self.RawValue: Argo.Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<Self> {
        switch json {
        case let .string(name) where name is Self.RawValue: return castValueToEnum(name)
        case let .number(value) where value is Self.RawValue: return castValueToEnum(value)
        default: return .failure(Argo.DecodeError.custom("Invalid \(Self.self) enum value"))
        }
    }
    
    private static func castValueToEnum(_ value: Any) -> Decoded<Self> {
        return .fromOptional(Self(rawValue: value as! Self.RawValue)) // swiftlint:disable:this force_cast
    }
    
}
