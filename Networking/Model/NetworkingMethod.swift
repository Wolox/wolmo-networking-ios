//
//  NetworkingMethod.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/24/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Alamofire

public enum NetworkingMethod: String {
    
    case options, get, head, post, put, patch, delete, trace, connect
    
}

internal extension NetworkingMethod {
    
    func toHTTPMethod() -> HTTPMethod {
        return HTTPMethod(rawValue: rawValue.uppercased())!
    }
    
}
