//
//  SessionManager.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/2/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import ReactiveSwift
import Result
import KeychainSwift

public protocol SessionManagerType {
    
    func bootstrapSession()
    
    var isLoggedIn: Bool { get }
    var currentUser: User? { get }
    var sessionToken: String? { get }
    
    var userSignal: Signal<User?, NoError> { get }
    
    func login(user: User)
    func update(user: User)
    func logout()
    func expire()
    
}

final public class SessionManager: SessionManagerType {

    fileprivate let _keychain: KeychainSwift
    fileprivate var _currentUserFetcher: CurrentUserFetcherType?
    
    fileprivate var _sessionToken: String? = .none
    fileprivate var _user: User? = .none
    
    public let sessionSignal: Signal<Bool, NoError>
    fileprivate let _sessionObserver: Signal<Bool, NoError>.Observer
    
    public let userSignal: Signal<User?, NoError>
    fileprivate let _userObserver: Signal<User?, NoError>.Observer
    
    public init(keychain: KeychainSwift = KeychainSwift()) {
        _keychain = keychain
        (sessionSignal, _sessionObserver) = Signal<Bool, NoError>.pipe()
        (userSignal, _userObserver) = Signal<User?, NoError>.pipe()
    }
    
    public func setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherType) {
        // TODO: Check this doesn't cause a leak.
        _currentUserFetcher = currentUserFetcher
    }
    
    public func bootstrapSession() {
        _sessionToken = getSessionToken()
        _sessionObserver.send(value: isLoggedIn)
        _currentUserFetcher?.fetchCurrentUser().startWithResult { [unowned self] in
            switch $0 {
            case .success(let user):
                self._user = user
                self._userObserver.send(value: user)
            case .failure(_):
                break
            }
        }
    }
    
    public var isLoggedIn: Bool {
        return sessionToken != .none
    }
    
    public var currentUser: User? {
        return _user
    }
    
    public var sessionToken: String? {
        return _sessionToken
    }
    
    deinit {
        _userObserver.sendCompleted()
        _sessionObserver.sendCompleted()
    }
    
}

public extension SessionManager {
    
    public func login(user: User) {
        updateSession(user: user)
        notifyObservers()
    }
    
    public func update(user: User) {
        updateSession(user: user)
    }
    
    public func logout() {
        updateSession(user: .none)
        notifyObservers()
    }
    
    public func expire() {
        updateSession(user: .none)
        notifyObservers()
    }
    
}

private extension SessionManager {
    
    func notifyObservers() {
        _sessionObserver.send(value: isLoggedIn)
        _userObserver.send(value: _user)
    }
    
    func updateSession(user: User?) {
        switch user {
        case .none: clearSession()
        case .some(let user): saveSession(user: user)
        }
    }
    
    func clearSession() {
        _user = .none
        _sessionToken = .none
        clearSessionToken()
    }
    
    func saveSession(user: User) {
        _user = user
        _sessionToken = user.sessionToken
        if let sessionToken = user.sessionToken {
            // This should always happen.
            saveSessionToken(sessionToken: sessionToken)
        }
    }
    
}

private extension SessionManager {
    
    private static let CurrentSessionTokenPersistanceKey = "com.wolox.wolmo-networking.CurrentSessionToken"
    
    func getSessionToken() -> String? {
        return _keychain.get(SessionManager.CurrentSessionTokenPersistanceKey)
    }
    
    func saveSessionToken(sessionToken: String) {
        _keychain.set(sessionToken, forKey: SessionManager.CurrentSessionTokenPersistanceKey)
    }
    
    func clearSessionToken() {
        _keychain.delete(SessionManager.CurrentSessionTokenPersistanceKey)
    }
    
}
