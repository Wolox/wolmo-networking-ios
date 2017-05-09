//
//  UserMock.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/24/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Networking

internal struct UserMock: AuthenticableUser {
    
    var sessionToken: String? = "fake-session-token"
    
}
