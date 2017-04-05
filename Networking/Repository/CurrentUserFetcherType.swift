//
//  CurrentUserFetcherType.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/2/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift

/**
    Protocol to be implemented by a repository intended to fetch the current user
    by the session manager.
    Remember in case this protocol is implemented, it must be injected to the
    `SessionManagerType` instance by the setter `setCurrentUserFetcher:`.
 */
public protocol CurrentUserFetcherType {

    func fetchCurrentUser() -> SignalProducer<AuthenticableUser, RepositoryError>
    
}
