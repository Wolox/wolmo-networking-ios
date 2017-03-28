//
//  AuthenticableUser.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/23/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Foundation

// This should be refactored. 
// Think of a struct which holds a sessionToken and a user.
// sessionToken should not be part of the user properties.
public protocol AuthenticableUser {
    
    var sessionToken: String? { get }
    
}
