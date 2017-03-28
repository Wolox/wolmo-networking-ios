//
//  AlamofireExtensions.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/1/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Alamofire
import ReactiveSwift
import enum Result.Result

internal typealias JSONResult = Result<AnyObject, NSError>

public struct ResponseError: Error {
    
    public let error: NSError
    public let body: NSDictionary?
}

internal extension Alamofire.DataRequest {
    
    func response() -> SignalProducer<(URLRequest, HTTPURLResponse, Data), ResponseError> {
        return SignalProducer { observable, disposable in
            disposable.add { self.task?.cancel() }
            
            guard self.request != .none else { return }
            
            AlamofireLogger.sharedInstance.logRequest(request: self.request!)
            
            self.response { dataResponse in
                if let error = dataResponse.error {
                    AlamofireLogger.sharedInstance.logError(error: error)
                    
                    let bodyDecode: () throws -> AnyObject = {
                        let data = dataResponse.data!
                        return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                    }
                    let result = JSONResult(attempt: bodyDecode)
                    observable.send(error: ResponseError(error: error as NSError, body: result.value as? NSDictionary))
                } else {
                    let request = dataResponse.request!
                    let response = dataResponse.response!
                    let data = dataResponse.data!
                    
                    AlamofireLogger.sharedInstance.logResponse(response: response, data: data)
                    observable.send(value: (request, response, data))
                    observable.sendCompleted()
                }
            }
        }
    }
    
}
