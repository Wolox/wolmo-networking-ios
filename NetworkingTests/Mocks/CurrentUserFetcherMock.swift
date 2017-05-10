//
//  CurrentUserFetcherMock.swift
//  Networking
//
//  Created by Pablo Giorgi on 5/8/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Networking
import ReactiveSwift
import Result

internal class CurrentUserFetcherMock: CurrentUserFetcherType {
    
    func fetchCurrentUser() -> SignalProducer<AuthenticableUser, RepositoryError> {
        return SignalProducer(value: UserMock())
    }
    
}
