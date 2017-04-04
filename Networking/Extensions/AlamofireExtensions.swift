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
internal typealias ResponseType = (URLRequest, HTTPURLResponse, Data)

public struct ResponseError: Error {
    
    public let error: NSError
    public let body: NSDictionary?
}

internal extension Alamofire.DataRequest {
    
    func response() -> SignalProducer<ResponseType, ResponseError> {
        return SignalProducer { observer, disposable in
            disposable.add { self.task?.cancel() }
            
            guard self.request != .none else { return }
            
            self.response { dataResponse in
                if let _ = dataResponse.error {
                    self.handleError(dataResponse: dataResponse, observer: observer)
                } else {
                    self.handleSuccess(dataResponse: dataResponse, observer: observer)
                }
            }
        }
    }
    
}

private extension Alamofire.DataRequest {
    
    func handleError(dataResponse: DefaultDataResponse, observer: Observer<ResponseType, ResponseError>) {
        let bodyDecode: () throws -> AnyObject = {
            let data = dataResponse.data!
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        }
        
        let error = dataResponse.error!
        let result = JSONResult(attempt: bodyDecode)
        observer.send(error: ResponseError(error: error as NSError, body: result.value as? NSDictionary))
    }
    
    func handleSuccess(dataResponse: DefaultDataResponse, observer: Observer<ResponseType, ResponseError>) {
        let request = dataResponse.request!
        let response = dataResponse.response!
        let data = dataResponse.data!
        
        observer.send(value: (request, response, data))
        observer.sendCompleted()
    }
    
}
