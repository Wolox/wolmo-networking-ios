//
//  NetworkingInterceptor.swift
//  Networking
//
//  Created by Nahuel Gladstein on 14/05/2019.
//  Copyright © 2019 Wolox. All rights reserved.
//

import Foundation

public protocol NetworkingInterceptor {
    func intercept(request: URLRequest, response: HTTPURLResponse, data: Data)
}
