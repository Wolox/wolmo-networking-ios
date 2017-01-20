//
//  AlamofireLoggerExtension.swift
//  Networking
//
//  Created by Pablo Giorgi on 9/14/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Alamofire

public final class AlamofireLogger {

    public static let sharedInstance = AlamofireLogger()
    
    public var logEnabled: Bool = false
    
}

public extension AlamofireLogger {
    
    func logRequest(request: URLRequest) {
        guard logEnabled else { return }
        
        logDivider()
        
        if let url = request.url?.absoluteString {
            print("Request: \(request.httpMethod!) \(url)")
        }
        
        if let headers = request.allHTTPHeaderFields {
            logHeaders(headers: headers as [String : AnyObject])
        }
    }
    
    func logResponse(response: URLResponse, data: Data? = .none) {
        guard logEnabled else { return }
        
        logDivider()
        
        if let url = response.url?.absoluteString {
            print("Response: \(url)")
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            let localizedStatus = HTTPURLResponse.localizedString(forStatusCode: statusCode).capitalized
            print("Status: \(statusCode) - \(localizedStatus)")
        }
        
        if let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: AnyObject] {
            logHeaders(headers: headers)
        }
        
        guard let data: Data = data as Data? else { return }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let pretty = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            if let string = NSString(data: pretty, encoding: String.Encoding.utf8.rawValue) {
                print("JSON: \(string)")
            }
        } catch {
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                print("Data: \(string)")
            }
        }
    }
    
    func logError(error: Error) {
        guard logEnabled else { return }
        
        logDivider()
        
        print("Error: \(error.localizedDescription)")
    }
    
}

private extension AlamofireLogger {
    
    func logDivider() {
        print("---------------------")
    }
    
    func logHeaders(headers: [String: AnyObject]) {
        print("Headers: [")
        for (key, value) in headers {
            print("  \(key) : \(value)")
        }
        print("]")
    }
    
}
