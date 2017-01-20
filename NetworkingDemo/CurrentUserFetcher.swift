//
//  CurrentUserFetcher.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/6/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Networking
import Foundation
import ReactiveSwift
import Argo
import Curry
import Runes
import Result

internal class CurrentUserFetcher: AbstractRepository, CurrentUserFetcherType {
    
    private static let UserPath = "users/"
    private static let CurrentUserPath = "me"
    
    func fetchCurrentUser() -> SignalProducer<User, RepositoryError> {
        let path = CurrentUserFetcher.UserPath + CurrentUserFetcher.CurrentUserPath
        return performRequest(method: .get, path: path, parameters: .none) {
            let decoded: Decoded<UserDemo> = decode($0)
            let result: Result<UserDemo, Argo.DecodeError> = decoded.toResult()
            if let user = result.value {
                return Result(value: user)
            }
            if let error: Argo.DecodeError = result.error  {
                return Result(error: error)
            }
            return Result(error: Argo.DecodeError.custom("User could not be decoded"))
        }
    }
    
}
