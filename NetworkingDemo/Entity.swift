//
//  Entity.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/6/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Argo
import Curry
import Runes

public struct Entity {
    
    let id: Int
    let genre: String
}

extension Entity: Argo.Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<Entity> {
        return curry(Entity.init)
            <^> json <| "id"
            <*> json <| "genre"
    }
    
}
