//
//  LoginRepository.swift
//  Networking
//
//  Created by Pablo Giorgi on 5/5/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift
import Networking
import Argo
import Result

internal protocol LoginRepositoryType {
    
    func login() -> SignalProducer<Void, RepositoryError>
    func failingLogin() -> SignalProducer<Void, RepositoryError>
    
}

internal class LoginRepository: AbstractRepository, LoginRepositoryType {
    
    func login() -> SignalProducer<Void, RepositoryError> {
        return performAuthenticationRequest(method: .post, path: "login") { _ in
            Result(value: ())
        }
    }
    
    func failingLogin() -> SignalProducer<Void, RepositoryError> {
        return performAuthenticationRequest(method: .post, path: "failing-login") { _ in
            Result(value: ())
        }
    }
    
}
