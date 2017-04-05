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


/**
    Protocol for session manager.
    Includes the functions to handle the different session status changes,
    and properties to get the session properties.
    Also notifies when the session changed.
 */
public protocol SessionManagerType {
    
    /**
        Bootstraps the session manager.
        This function loads the session token (in case there's any)
        and sends a session status change signal. It also fetches
        the user (in case a user fetcher has been provided) and sends 
        a user change signal.
     */
    func bootstrap()
    
    /**
        Returns whether there is an active session.
     */
    var isLoggedIn: Bool { get }
    
    /**
        Returns the current user in case there is an active session.
     */
    var currentUser: AuthenticableUser? { get }
    
    /**
        Return the current session token in case there is an active session.
     */
    var sessionToken: String? { get }
    
    /**
        Signal that notifies each time the session status changes.
        Its value is a Bool representing whether there is an active session.
        Useful to handle the application status based on the session status.
     */
    var sessionSignal: Signal<Bool, NoError> { get }
    
    /**
        Signal that notifies each time the user changes.
        Its value is a User representing the current user.
        Useful to keep the user up to date any time it's fetched or updated.
     */
    var userSignal: Signal<AuthenticableUser?, NoError> { get }
    
    /**
        Set the current user fecther used to fetch the user when the 
        session manager is bootstrapped.
        This is necessary since the user is not stored locally.
     */
    func setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherType)
    
    /**
        This function must be called manually when a user is logged in.
        It will send both a session and user notification.
     
        - Parameters:
            - user: user to initialize the session from.
     */
    func login(user: AuthenticableUser)
    
    /**
        This function can be called manually when a user is fetched from
        outside the session manager. In case the current user is wanted 
        to be up to date with the fetched one.
        It will send no notifications, since the session status
        remains the same.
     
        - Parameters:
            - user: user to initialize the session from.
     */
    func update(user: AuthenticableUser)
    
    /**
        This function must be called manually when a user is logged out.
        It will send both a session and user notification.
     */
    func logout()
    
    /**
        This function is called automatically by a repository when
        the session expires and the client is notified by the server.
        No need to be called manually.
     */
    func expire()
    
}

/**
    Default SessionManager responsible for handling the session in the application.
    It uses Keychain to store securely the session token in local storage, and a repository
    to fetch the user when it's bootstrapped.
 */
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
                // TODO: Handle error here.
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
