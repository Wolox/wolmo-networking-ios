//
//  Entity.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/24/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Argo
import Curry
import Runes

internal struct Entity {
    
    public let id: Int
    public let name: String
    public let optional: Bool?
    
}

extension Entity: Argo.Decodable {
    
    static func decode(_ json: JSON) -> Decoded<Entity> {
        return curry(Entity.init)
            <^> json <| "id"
            <*> json <| "name"
            <*> (json <|? "optional" <|> pure(.none))
    }
    
}
