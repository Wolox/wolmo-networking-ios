//
//  User.swift
//  Networking
//
//  Copyright © 2019 Wolox. All rights reserved.
//

import Networking
import Argo
import Curry
import Runes

struct User {
    let sessionToken: String?
    let id: Int
}

extension User: Argo.Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<User> {
        return curry(User.init)
            <^> json <|? "session_token"
            <*> json <| "id"
    }
    
}
