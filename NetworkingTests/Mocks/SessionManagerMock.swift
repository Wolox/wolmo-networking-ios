//
//  SessionManagerMock.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/24/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift
import Result
import Networking

internal class SessionManagerMock: SessionManagerType {
    
    var sessionSignal: Signal<Bool, NoError> = Signal<Bool, NoError>.pipe().0
    var userSignal: Signal<AuthenticableUser?, NoError> = Signal<AuthenticableUser?, NoError>.pipe().0
    
    var _currentUser: AuthenticableUser? = .none
    var _sessionToken: String? = .none
    
    func bootstrap() {
        
    }
    
    func setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherType) {
        
    }
    
    var isLoggedIn: Bool {
        return _sessionToken != .none
    }
    
    var currentUser: AuthenticableUser? {
        return _currentUser
    }
    
    var sessionToken: String? {
        return _currentUser?.sessionToken
    }
    
    func login(user: AuthenticableUser) {
        _currentUser = user
        _sessionToken = user.sessionToken
    }
    
    func update(user: AuthenticableUser) {
        _currentUser = user
        _sessionToken = user.sessionToken
    }
    
    func expire() {
        _currentUser = .none
        _sessionToken = .none
    }
    
    func logout() {
        _currentUser = .none
        _sessionToken = .none
    }
    
}
