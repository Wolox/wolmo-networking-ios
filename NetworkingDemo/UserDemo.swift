//
//  UserDemo.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/6/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Networking
import Argo
import Curry
import Runes

struct UserDemo: AuthenticableUser {
    
    let sessionToken: String?
    let id: Int
}

extension UserDemo: Argo.Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<UserDemo> {
        return curry(UserDemo.init)
            <^> json <|? "session_token"
            <*> json <| "id"
    }
    
}
