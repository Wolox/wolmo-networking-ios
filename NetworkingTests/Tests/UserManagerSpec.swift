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

internal class UserManagerSpec: QuickSpec {
    
    private static let CurrentSessionTokenPersistanceKey = "com.wolox.wolmo-networking.CurrentSessionToken"
    
    override func spec() {
        
        var keychainService: KeychainServiceType!
        var userManager: UserManagerType!
        
        func initializeSessionManager() {
            keychainService = KeychainServiceMock()
            userManager = UserManager(keychainService: keychainService)
        }
        
        func initializeAuthenticatedSessionManager() {
            keychainService = KeychainServiceMock()
            keychainService.set(value: UserMock().sessionToken!,
                                forKey: UserManagerSpec.CurrentSessionTokenPersistanceKey)
            userManager = UserManager(keychainService: keychainService)
        }
        
        describe("#isLoggedIn") {
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    initializeSessionManager()
                    userManager.bootstrap()
                }
                
                it("returns there is no session") {
                    expect(userManager.isLoggedIn).to(beFalse())
                }
                
            }
            
            context("when bootstraps and there is a session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    userManager.bootstrap()
                }
                
                it("returns there is a session") {
                    expect(userManager.isLoggedIn).to(beTrue())
                }
                
            }
            
        }
        
        describe("#sessionToken") {
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    initializeSessionManager()
                    userManager.bootstrap()
                }
                
                it("returns none") {
                    expect(userManager.sessionToken).to(beNil())
                }
                
            }
            
            context("when bootstraps and there is a session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    userManager.bootstrap()
                }
                
                it("returns stored session token") {
                    expect(userManager.sessionToken).to(equal(UserMock().sessionToken))
                }
                
            }
            
        }
        
        describe("#currentUser") {
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    initializeSessionManager()
                    userManager.bootstrap()
                }
                
                it("returns none") {
                    expect(userManager.currentUser).to(beNil())
                }
                
            }
            
            context("when bootstraps and there is a session but no user fetcher") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    userManager.bootstrap()
                }
                
                it("returns none") {
                    expect(userManager.currentUser).to(beNil())
                }
                
            }
            
            context("when bootstraps and there is a session and a user fetcher") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    userManager.setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherMock())
                    userManager.bootstrap()
                }
                
                it("returns the fetched current user") {
                    expect(userManager.currentUser!.sessionToken).to(equal(UserMock().sessionToken))
                }
                
            }
            
        }
        
        describe("#sessionSignal") {
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    initializeSessionManager()
                }
                
                it("sends false in session signal") { waitUntil { done in
                    userManager.sessionSignal.successOnFalse { done() }
                    userManager.bootstrap()
                }}
                
            }
            
            context("when bootstraps and there is a session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                }
                
                it("sends true in session signal") { waitUntil { done in
                    userManager.sessionSignal.successOnTrue { done() }
                    userManager.bootstrap()
                }}
                
            }
            
        }
        
        describe("#userSignal") {
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    initializeSessionManager()
                }
                
                it("sends none in user signal") { waitUntil { done in
                    userManager.userSignal.successOnNone { done() }
                    userManager.bootstrap()
                }}
                
            }
            
            context("when bootstraps and there is a session but no user fetcher") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                }
                
                it("sends none in user signal") { waitUntil { done in
                    userManager.userSignal.successOnNone { done() }
                    userManager.bootstrap()
                }}
                
            }
            
            context("when bootstraps and there is a session and a user fetcher") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    userManager.setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherMock())
                }
                
                it("sends the authenticated user in user signal") { waitUntil { done in
                    userManager.userSignal.successOnSome {
                        expect($0.sessionToken).to(equal(UserMock().sessionToken))
                        done()
                    }
                    userManager.bootstrap()
                }}
                
            }
            
        }
        
        describe("#login") {
            
            describe("when there is a current session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    userManager.bootstrap()
                }
                
                it("throws an assertion error") {
                    expect(userManager.login(user: UserMock())).to(throwAssertion())
                }
                
            }
            
            describe("when there is no current session") {
                
                beforeEach {
                    initializeSessionManager()
                    userManager.bootstrap()
                }
                
                it("sends true in session signal") { waitUntil { done in
                    userManager.sessionSignal.successOnTrue { done() }
                    userManager.login(user: UserMock())
                }}
                
                it("sends the authenticated user in user signal") { waitUntil { done in
                    userManager.userSignal.successOnSome {
                        expect($0.sessionToken).to(equal(UserMock().sessionToken))
                        done()
                    }
                    
                    userManager.login(user: UserMock())
                }}
                
                it("returns the session token") {
                    userManager.login(user: UserMock())
                    expect(userManager.currentUser!.sessionToken).to(equal(UserMock().sessionToken))
                }
                
                it("returns the current user") {
                    userManager.login(user: UserMock())
                    expect(userManager.sessionToken).to(equal(UserMock().sessionToken))
                }

            }
            
        }
        
        describe("#update") {
            
            describe("when there is no current session") {
                
                beforeEach {
                    initializeSessionManager()
                    userManager.bootstrap()
                }
                
                it("throws an assertion error") {
                    expect(userManager.update(user: UserMock())).to(throwAssertion())
                }
                
            }
            
            describe("when there is a current session") {
                
                let updatedSessionToken = "updated-fake-session-token"
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    userManager.bootstrap()
                }
                
                it("sends the updated authenticated user in user signal") { waitUntil { done in
                    userManager.userSignal.successOnSome {
                        expect($0.sessionToken).to(equal(updatedSessionToken))
                        done()
                    }
                    
                    var updatedUser = UserMock()
                    updatedUser.sessionToken = updatedSessionToken
                    userManager.update(user: updatedUser)
                }}
                
                it("updates the current user") {
                    var updatedUser = UserMock()
                    updatedUser.sessionToken = updatedSessionToken
                    userManager.update(user: updatedUser)
                    expect(userManager.currentUser!.sessionToken).to(equal(updatedSessionToken))
                }
                
            }
            
        }
        
        describe("#logout") {
            
            describe("when there is no current session") {
                
                beforeEach {
                    initializeSessionManager()
                    userManager.bootstrap()
                }
                
                it("throws an assertion error") {
                    expect(userManager.logout()).to(throwAssertion())
                }
                
            }
            
            describe("when there is a current session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    userManager.bootstrap()
                }
                
                it("sends false in session signal") { waitUntil { done in
                    userManager.sessionSignal.successOnFalse { done() }
                    userManager.logout()
                }}
                
                it("sends none in user signal") { waitUntil { done in
                    userManager.userSignal.successOnNone { done() }
                    userManager.logout()
                }}
                
                it("clears the current user") {
                    userManager.logout()
                    expect(userManager.currentUser).to(beNil())
                }
                
                it("clears the session token") {
                    userManager.logout()
                    expect(userManager.sessionToken).to(beNil())
                }
                
            }
            
        }
        
        describe("#expire") {
            
            describe("when there is no current session") {
                
                beforeEach {
                    initializeSessionManager()
                    userManager.bootstrap()
                }
                
                it("throws an assertion error") {
                    expect(userManager.expire()).to(throwAssertion())
                }
                
            }
            
            describe("when there is a current session") {
                
                beforeEach {
                    initializeAuthenticatedSessionManager()
                    userManager.bootstrap()
                }
                
                it("sends false in session signal") { waitUntil { done in
                    userManager.sessionSignal.successOnFalse { done() }
                    userManager.expire()
                }}
                
                it("sends none in user signal") { waitUntil { done in
                    userManager.userSignal.successOnNone { done() }
                    userManager.expire()
                }}
                
                it("clears the current user") {
                    userManager.expire()
                    expect(userManager.currentUser).to(beNil())
                }
                
                it("clears the session token") {
                    userManager.expire()
                    expect(userManager.sessionToken).to(beNil())
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
