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
    let id: Int //swift-lint:disable:this variable_name
    
}

extension UserDemo: Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<UserDemo> {
        
        // Split expression into intermediate assignments to get past Swift's compiler limitations - feels super wrong
        // See https://github.com/thoughtbot/Argo/issues/5
        
        return curry(UserDemo.init)
            <^> json <|? "session_token"
            <*> json <| "id"
    }
    
}
