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

/**
    Tuple that represents the parameters of a request and a response.
 */
internal typealias ResponseType = (URLRequest, HTTPURLResponse, Data)

/**
    Error representing a response error. It includes the error itself and
    the body received in the failed response.
 */
public struct ResponseError: Error {
    
    public let error: NSError
    public let body: NSDictionary?
    public let statusCode: Int
    
}

/**
    Extension that wraps Alamofire response, returning the request
    response as a SignalProducer, where its value is a ResponseType tuple
    and its error a ResponseError.
 */
internal extension Alamofire.DataRequest {
    
    func response() -> SignalProducer<ResponseType, ResponseError> {
        return SignalProducer { observer, disposable in
            disposable.observeEnded { self.task?.cancel() }
            
            guard self.request != .none else { return }
            
            self.response { dataResponse in
                if dataResponse.error != nil {
                    self.handleError(dataResponse: dataResponse, observer: observer)
                } else {
                    self.handleSuccess(dataResponse: dataResponse, observer: observer)
                }
            }
        }
    }
    
}

private extension Alamofire.DataRequest {
    
    static let NoNetworkConnectionStatusCode = 0 // response is .none in case there is no connection
    
    func handleError(dataResponse: DefaultDataResponse, observer: Signal<ResponseType, ResponseError>.Observer) {
        let bodyDecode: () throws -> AnyObject = {
            let data = dataResponse.data!
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        }
        
        let error = dataResponse.error! as NSError
        let bodyResult = JSONResult(attempt: bodyDecode)
        let body = bodyResult.value as? NSDictionary ?? [:]
        let statusCode = checkStatusCode(response: dataResponse.response, error: error)
        observer.send(error: ResponseError(error: error, body: body, statusCode: statusCode))
    }
    
    func checkStatusCode(response: HTTPURLResponse?, error: NSError) -> Int {
        if error.code == NSURLErrorTimedOut {
            return NSURLErrorTimedOut
        }
        return response?.statusCode ?? DataRequest.NoNetworkConnectionStatusCode
    }
    
    func handleSuccess(dataResponse: DefaultDataResponse, observer: Signal<ResponseType, ResponseError>.Observer) {
        // These properties can be unwrapped safely given no error was encountered.
        let request = dataResponse.request!
        let response = dataResponse.response!
        let data = dataResponse.data!
        
        observer.send(value: (request, response, data))
        observer.sendCompleted()
    }
    
}
