//
//  UserMock.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/24/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Foundation
@testable import Networking

internal struct UserMock: User {
    
    var sessionToken: String? {
        return "fake-session-token"
    }

}
