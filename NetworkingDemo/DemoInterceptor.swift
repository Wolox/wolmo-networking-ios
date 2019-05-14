//
//  DemoInterceptor.swift
//  NetworkingDemo
//
//  Created by Nahuel Gladstein on 14/05/2019.
//  Copyright © 2019 Wolox. All rights reserved.
//

import Foundation
import Networking

public class DemoInterceptor: NetworkingInterceptor {
    public func intercept(request: URLRequest, response: HTTPURLResponse, data: Data) {
        let title = "\n- - - I N T E R C E P T O R - - - \n"
        let contentType = "\n   \(response.allHeaderFields["Content-Type"]!)"
        print("\(title) For example lets print the content type: \(contentType) \(title)")
    }
    
}
