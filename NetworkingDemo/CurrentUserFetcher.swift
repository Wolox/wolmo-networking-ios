//
//  CurrentUserFetcher.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/6/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Networking
import ReactiveSwift
import Argo
import Result

internal class CurrentUserFetcher: AbstractRepository, CurrentUserFetcherType {
    
    private static let UserPath = "users"
    private static let CurrentUserPath = "me"
    
    func fetchCurrentUser() -> SignalProducer<AuthenticableUser, RepositoryError> {
        let path = CurrentUserFetcher.UserPath / CurrentUserFetcher.CurrentUserPath
        return performRequest(method: .get, path: path) {
            let result: Result<UserDemo, Argo.DecodeError> = decode($0).toResult()
            return result.map { $0 }
        }
    }
    
}
