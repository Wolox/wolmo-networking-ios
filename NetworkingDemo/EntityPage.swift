//
//  EntityPage.swift
//  NetworkingDemo
//
//  Created by Nahuel Gladstein on 04/02/2019.
//  Copyright © 2019 Wolox. All rights reserved.
//

import Argo
import Curry
import Runes

public struct EntityPage {
    let data: [Entity]
    let currentPage: Int
}

extension EntityPage: Argo.Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<EntityPage> {
        return curry(EntityPage.init)
            <^> json <|| "data"
            <*> json <| ["page", "position", "current"]
    }
    
}
