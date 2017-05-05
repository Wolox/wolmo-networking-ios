//
//  LocalRequestExecutor.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/24/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift
@testable import Networking

internal class LocalRequestExecutor: RequestExecutorType {
    
    func perform(method: NetworkingMethod,
                 url: URL,
                 parameters: [String: Any]? = .none,
                 headers: [String: String]? = .none) -> HTTPResponseProducer {
        let path = buildPath(method: method, url: url)
        
        if let filePath = jsonPathForFile(name: path) {
            if requestRequiresAuthentication(url: url) && !requestIsAuthenticated(headers: headers) {
                let error = unauthenticatedError
                return SignalProducer(error: ResponseError(error: error, body: .none, statusCode: error.code))
            }
            let request = URLRequest(url: url)
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: .none, headerFields: .none)!
            let data = jsonData(forPath: filePath)
            return SignalProducer(value: (request, response, data))
        }
        
        let error = notFoundError
        return SignalProducer(error: ResponseError(error: error, body: .none, statusCode: error.code))
    }
    
}

private extension LocalRequestExecutor {
    
    func requestRequiresAuthentication(url: URL) -> Bool {
        return !url.absoluteString.contains("login")
    }
    
    func requestIsAuthenticated(headers: [String: String]?) -> Bool {
        return headers?["Authorization"] != .none
    }
    
    var notFoundError: NSError {
        return NSError(domain: "Not found URL", code: 400, userInfo: [NSLocalizedDescriptionKey: "400"])
    }
    
    var unauthenticatedError: NSError {
        return NSError(domain: "Unauthorized", code: 401, userInfo: [NSLocalizedDescriptionKey: "401"])
    }
    
}

private extension LocalRequestExecutor {
    
    func buildPath(method: NetworkingMethod, url: URL) -> String {
        return (method.rawValue.uppercased() + ":" + url.absoluteString)
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: "/", with: "-")
    }
    
    var bundleTest: Bundle {
        return Bundle(for: type(of: self))
    }
    
    func jsonPathForFile(name: String) -> String? {
        if let url = bundleTest.url(forResource: name, withExtension: "json") {
            return url.path
        }
        return .none
    }
    
    func jsonData(forPath path: String) -> Data {
        return try! NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe) as Data
    }
    
}
