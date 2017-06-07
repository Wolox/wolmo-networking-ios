//
//  EnumEntity.swift
//  Networking
//
//  Created by Nahuel Gladstein on 6/7/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Argo
import Curry
import Runes

internal struct EnumEntity {
    
    public let id: Int
    public let name: String
    public let state: EnumEntityState
    
}

extension EnumEntity: Decodable {
    
    static func decode(_ json: JSON) -> Decoded<EnumEntity> {
        return curry(EnumEntity.init)
            <^> json <| "id"
            <*> json <| "name"
            <*> json <| "state"
    }
    
}
