//
//  CurrentUserFetcherType.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/2/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift

public protocol CurrentUserFetcherType {

    func fetchCurrentUser() -> SignalProducer<AuthenticableUser, RepositoryError>
    
}
