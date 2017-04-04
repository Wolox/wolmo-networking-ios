//
//  CurrentUserFetcherType.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/2/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift

// TODO: Document that even if this protocol is implemented, the class
// must be injected to `SessionManager` by the setter `setCurrentUserFetcher:`
public protocol CurrentUserFetcherType {

    func fetchCurrentUser() -> SignalProducer<AuthenticableUser, RepositoryError>
    
}
