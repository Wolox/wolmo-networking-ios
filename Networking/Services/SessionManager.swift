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
    
    func bootstrap()
    
    var isLoggedIn: Bool { get }
    var currentUser: AuthenticableUser? { get }
    var sessionToken: String? { get }
    
    var sessionSignal: Signal<Bool, NoError> { get }
    var userSignal: Signal<AuthenticableUser?, NoError> { get }
    
    func setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherType)
    
    func login(user: AuthenticableUser)
    func update(user: AuthenticableUser)
    func logout()
    func expire()
    
}

final public class SessionManager: SessionManagerType {

    fileprivate let _keychain: KeychainSwift
    fileprivate var _currentUserFetcher: CurrentUserFetcherType?
    
    public fileprivate(set) var sessionToken: String? = .none
    public fileprivate(set) var currentUser: AuthenticableUser? = .none
    
    public let sessionSignal: Signal<Bool, NoError>
    fileprivate let _sessionObserver: Signal<Bool, NoError>.Observer
    
    public let userSignal: Signal<AuthenticableUser?, NoError>
    fileprivate let _userObserver: Signal<AuthenticableUser?, NoError>.Observer
    
    public init(keychain: KeychainSwift = KeychainSwift()) {
        _keychain = keychain
        (sessionSignal, _sessionObserver) = Signal<Bool, NoError>.pipe()
        (userSignal, _userObserver) = Signal<AuthenticableUser?, NoError>.pipe()
    }
    
    public func setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherType) {
        // TODO: Check this doesn't cause a leak.
        _currentUserFetcher = currentUserFetcher
    }
    
    public func bootstrap() {
        sessionToken = getSessionToken()
        _sessionObserver.send(value: isLoggedIn)
        _currentUserFetcher?.fetchCurrentUser().startWithResult { [unowned self] in
            switch $0 {
            case .success(let user):
                self.currentUser = user
                self._userObserver.send(value: user)
            case .failure(_):
                break
            }
        }
    }
    
    public var isLoggedIn: Bool {
        return sessionToken != .none
    }
    
    deinit {
        _userObserver.sendCompleted()
        _sessionObserver.sendCompleted()
    }
    
}

public extension SessionManager {
    
    public func login(user: AuthenticableUser) {
        updateSession(user: user)
        notifyObservers()
    }
    
    public func update(user: AuthenticableUser) {
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
        _userObserver.send(value: currentUser)
    }
    
    func updateSession(user: AuthenticableUser?) {
        switch user {
        case .none: clearSession()
        case .some(let user): saveSession(user: user)
        }
    }
    
    func clearSession() {
        currentUser = .none
        sessionToken = .none
        clearSessionToken()
    }
    
    func saveSession(user: AuthenticableUser) {
        currentUser = user
        sessionToken = user.sessionToken
        if let sessionToken = user.sessionToken {
            saveSessionToken(sessionToken: sessionToken)
        } else {
            fatalError("Authenticated user has no session token, unable to save session in SessionManager")
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
