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
    
    let id: Int
    let name: String
    let stringState: EnumStringEntityState
    let uintState: EnumUIntEntityState
    let floatState: EnumFloatEntityState
    let doubleState: EnumDoubleEntityState
    
}

extension EnumEntity: Argo.Decodable {
    
    static func decode(_ json: JSON) -> Decoded<EnumEntity> {
        return curry(EnumEntity.init)
            <^> json <| "id"
            <*> json <| "name"
            <*> json <| "string_state"
            <*> json <| "uint_state"
            <*> json <| "float_state"
            <*> json <| "double_state"
    }
    
}
