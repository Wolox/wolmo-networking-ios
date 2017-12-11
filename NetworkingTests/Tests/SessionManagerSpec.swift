//
//  SessionManagerSpec.swift
//  Networking
//
//  Created by Pablo Giorgi on 5/8/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Quick
import Nimble
import ReactiveSwift
import Result
@testable import Networking

internal class SessionManagerSpec: QuickSpec {
    
    private static let CurrentSessionTokenPersistanceKey = "com.wolox.wolmo-networking.CurrentSessionToken"
    
    override func spec() {
        
        var keychainService: KeychainServiceType!
        var sessionManager: SessionManagerType!
        
        func initializeSessionManager() {
            keychainService = KeychainServiceMock()
            sessionManager = SessionManager(keychainService: keychainService)
        }
        
        func initializeAuthenticatedSessionManager() {
            keychainService = KeychainServiceMock()
            keychainService.set(value: UserMock().sessionToken!,
                                forKey: SessionManagerSpec.CurrentSessionTokenPersistanceKey)
            sessionManager = SessionManager(keychainService: keychainService)
        }
        
        describe("#isLoggedIn") {
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    initializeSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("returns there is no session") {
                    expect(sessionManager.isLoggedIn).to(beFalse())
                }
                
            }
            
            context("when bootstraps and there is a session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("returns there is a session") {
                    expect(sessionManager.isLoggedIn).to(beTrue())
                }
                
            }
            
        }
        
        describe("#sessionToken") {
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    initializeSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("returns none") {
                    expect(sessionManager.sessionToken).to(beNil())
                }
                
            }
            
            context("when bootstraps and there is a session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("returns stored session token") {
                    expect(sessionManager.sessionToken).to(equal(UserMock().sessionToken))
                }
                
            }
            
        }
        
        describe("#currentUser") {
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    initializeSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("returns none") {
                    expect(sessionManager.currentUser).to(beNil())
                }
                
            }
            
            context("when bootstraps and there is a session but no user fetcher") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("returns none") {
                    expect(sessionManager.currentUser).to(beNil())
                }
                
            }
            
            context("when bootstraps and there is a session and a user fetcher") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    sessionManager.setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherMock())
                    sessionManager.bootstrap()
                }
                
                it("returns the fetched current user") {
                    expect(sessionManager.currentUser!.sessionToken).to(equal(UserMock().sessionToken))
                }
                
            }
            
        }
        
        describe("#sessionSignal") {
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    initializeSessionManager()
                }
                
                it("sends false in session signal") { waitUntil { done in
                    sessionManager.sessionSignal.successOnFalse { done() }
                    sessionManager.bootstrap()
                }}
                
            }
            
            context("when bootstraps and there is a session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                }
                
                it("sends true in session signal") { waitUntil { done in
                    sessionManager.sessionSignal.successOnTrue { done() }
                    sessionManager.bootstrap()
                }}
                
            }
            
        }
        
        describe("#userSignal") {
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    initializeSessionManager()
                }
                
                it("sends none in user signal") { waitUntil { done in
                    sessionManager.userSignal.successOnNone { done() }
                    sessionManager.bootstrap()
                }}
                
            }
            
            context("when bootstraps and there is a session but no user fetcher") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                }
                
                it("sends none in user signal") { waitUntil { done in
                    sessionManager.userSignal.successOnNone { done() }
                    sessionManager.bootstrap()
                }}
                
            }
            
            context("when bootstraps and there is a session and a user fetcher") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    sessionManager.setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherMock())
                }
                
                it("sends the authenticated user in user signal") { waitUntil { done in
                    sessionManager.userSignal.successOnSome {
                        expect($0.sessionToken).to(equal(UserMock().sessionToken))
                        done()
                    }
                    sessionManager.bootstrap()
                }}
                
            }
            
        }
        
        describe("#login") {
            
            describe("when there is a current session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("throws an assertion error") {
                    expect(sessionManager.login(user: UserMock())).to(throwAssertion())
                }
                
            }
            
            describe("when there is no current session") {
                
                beforeEach {
                    initializeSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("sends true in session signal") { waitUntil { done in
                    sessionManager.sessionSignal.successOnTrue { done() }
                    sessionManager.login(user: UserMock())
                }}
                
                it("sends the authenticated user in user signal") { waitUntil { done in
                    sessionManager.userSignal.successOnSome {
                        expect($0.sessionToken).to(equal(UserMock().sessionToken))
                        done()
                    }
                    
                    sessionManager.login(user: UserMock())
                }}
                
                it("returns the session token") {
                    sessionManager.login(user: UserMock())
                    expect(sessionManager.currentUser!.sessionToken).to(equal(UserMock().sessionToken))
                }
                
                it("returns the current user") {
                    sessionManager.login(user: UserMock())
                    expect(sessionManager.sessionToken).to(equal(UserMock().sessionToken))
                }

            }
            
        }
        
        describe("#update") {
            
            describe("when there is no current session") {
                
                beforeEach {
                    initializeSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("throws an assertion error") {
                    expect(sessionManager.update(user: UserMock())).to(throwAssertion())
                }
                
            }
            
            describe("when there is a current session") {
                
                let updatedSessionToken = "updated-fake-session-token"
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("sends the updated authenticated user in user signal") { waitUntil { done in
                    sessionManager.userSignal.successOnSome {
                        expect($0.sessionToken).to(equal(updatedSessionToken))
                        done()
                    }
                    
                    var updatedUser = UserMock()
                    updatedUser.sessionToken = updatedSessionToken
                    sessionManager.update(user: updatedUser)
                }}
                
                it("updates the current user") {
                    var updatedUser = UserMock()
                    updatedUser.sessionToken = updatedSessionToken
                    sessionManager.update(user: updatedUser)
                    expect(sessionManager.currentUser!.sessionToken).to(equal(updatedSessionToken))
                }
                
            }
            
        }
        
        describe("#logout") {
            
            describe("when there is no current session") {
                
                beforeEach {
                    initializeSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("throws an assertion error") {
                    expect(sessionManager.logout()).to(throwAssertion())
                }
                
            }
            
            describe("when there is a current session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("sends false in session signal") { waitUntil { done in
                    sessionManager.sessionSignal.successOnFalse { done() }
                    sessionManager.logout()
                }}
                
                it("sends none in user signal") { waitUntil { done in
                    sessionManager.userSignal.successOnNone { done() }
                    sessionManager.logout()
                }}
                
                it("clears the current user") {
                    sessionManager.logout()
                    expect(sessionManager.currentUser).to(beNil())
                }
                
                it("clears the session token") {
                    sessionManager.logout()
                    expect(sessionManager.sessionToken).to(beNil())
                }
                
            }
            
        }
        
        describe("#expire") {
            
            describe("when there is no current session") {
                
                beforeEach {
                    initializeSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("throws an assertion error") {
                    expect(sessionManager.expire()).to(throwAssertion())
                }
                
            }
            
            describe("when there is a current session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    sessionManager.bootstrap()
                }
                
                it("sends false in session signal") { waitUntil { done in
                    sessionManager.sessionSignal.successOnFalse { done() }
                    sessionManager.expire()
                }}
                
                it("sends none in user signal") { waitUntil { done in
                    sessionManager.userSignal.successOnNone { done() }
                    sessionManager.expire()
                }}
                
                it("clears the current user") {
                    sessionManager.expire()
                    expect(sessionManager.currentUser).to(beNil())
                }
                
                it("clears the session token") {
                    sessionManager.expire()
                    expect(sessionManager.sessionToken).to(beNil())
                }
                
            }
            
        }
        
    }
    
}

private extension Signal where Value == Bool, Error == NoError {
    
    func successOnTrue(closure: @escaping () -> Void) {
        observeValues {
            switch $0 {
            case true: closure()
            case false: fail()
            }
        }
    }
    
    func successOnFalse(closure: @escaping () -> Void) {
        observeValues {
            switch $0 {
            case true: fail()
            case false: closure()
            }
        }
    }
    
}

private extension Signal where Value == AuthenticableUser?, Error == NoError {
    
    func successOnSome(closure: @escaping (AuthenticableUser) -> Void) {
        observeValues {
            switch $0 {
            case .some(let user): closure(user)
            case .none: fail()
            }
        }
    }
    
    func successOnNone(closure: @escaping () -> Void) {
        observeValues {
            switch $0 {
            case .some: fail()
            case .none: closure()
            }
        }
    }
    
}
