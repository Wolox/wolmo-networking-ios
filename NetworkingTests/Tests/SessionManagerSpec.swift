//
//  SessionManagerSpec.swift
//  Networking
//
//  Created by Pablo Giorgi on 5/8/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Quick
import Nimble
@testable import Networking

internal class SessionManagerSpec: QuickSpec {
    
    private static let CurrentSessionTokenPersistanceKey = "com.wolox.wolmo-networking.CurrentSessionToken"
    
    override func spec() {
        
        var keychainService: KeychainServiceType!
        var sessionManager: SessionManagerType!
        
        describe("#isLoggedIn") {
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.bootstrap()
                }
                
                it("returns there is no session") {
                    expect(sessionManager.isLoggedIn).to(beFalse())
                }
                
            }
            
            context("when bootstraps and there is already a session") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    keychainService.set(value: UserMock().sessionToken!,
                                        forKey: SessionManagerSpec.CurrentSessionTokenPersistanceKey)
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.bootstrap()
                }
                
                it("returns there is no session") {
                    expect(sessionManager.isLoggedIn).to(beTrue())
                }
                
            }
            
        }
        
        describe("#sessionToken") {
            
            context("when bootstraps and there is already a session") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    keychainService.set(value: UserMock().sessionToken!,
                                        forKey: SessionManagerSpec.CurrentSessionTokenPersistanceKey)
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.bootstrap()
                }
                
                it("returns stored session token") {
                    expect(sessionManager.sessionToken).to(equal(UserMock().sessionToken))
                }
                
            }
            
        }
        
        describe("#currentUser") {
            
            context("when bootstraps and there is already a session and a user fetcher") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    keychainService.set(value: UserMock().sessionToken!,
                                        forKey: SessionManagerSpec.CurrentSessionTokenPersistanceKey)
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherMock())
                    sessionManager.bootstrap()
                }
                
                it("returns the fetched current user") {
                    expect(sessionManager.currentUser!.sessionToken).to(equal(UserMock().sessionToken))
                }
                
            }
            
        }
        
        describe("#sessionSignal") {
            
            context("when bootstraps and there is already a session") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    keychainService.set(value: UserMock().sessionToken!,
                                        forKey: SessionManagerSpec.CurrentSessionTokenPersistanceKey)
                    sessionManager = SessionManager(keychainService: keychainService)
                }
                
                it("sends false in session signal") { waitUntil { done in
                    sessionManager.sessionSignal.observeValues {
                        switch $0 {
                        case true: done()
                        case false: fail()
                        }
                    }
                    
                    sessionManager.bootstrap()
                }}
                
            }
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    sessionManager = SessionManager(keychainService: keychainService)
                }
                
                it("sends true in session signal") { waitUntil { done in
                    sessionManager.sessionSignal.observeValues {
                        switch $0 {
                        case true: fail()
                        case false: done()
                        }
                    }
                    
                    sessionManager.bootstrap()
                }}
                
            }
            
        }
        
        describe("#userSignal") {
            
            context("when bootstraps and there is already a session and a user fetcher") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    keychainService.set(value: UserMock().sessionToken!,
                                        forKey: SessionManagerSpec.CurrentSessionTokenPersistanceKey)
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.setCurrentUserFetcher(currentUserFetcher: CurrentUserFetcherMock())
                }
                
                it("sends the authenticated user in user signal") { waitUntil { done in
                    sessionManager.userSignal.observeValues {
                        switch $0 {
                        case .none: fail()
                        case .some(let user):
                            expect(user.sessionToken).to(equal(UserMock().sessionToken))
                            done()
                        }
                    }
                    
                    sessionManager.bootstrap()
                }}
                
            }
            
            context("when bootstraps and there is already a session and no user fetcher") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    keychainService.set(value: UserMock().sessionToken!,
                                        forKey: SessionManagerSpec.CurrentSessionTokenPersistanceKey)
                    sessionManager = SessionManager(keychainService: keychainService)
                }
                
                it("sends the authenticated user in user signal") { waitUntil { done in
                    sessionManager.userSignal.observeValues {
                        switch $0 {
                        case .none: done()
                        case .some: fail()
                        }
                    }
                    
                    sessionManager.bootstrap()
                }}
                
            }
            
            context("when bootstraps and there is no session") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    sessionManager = SessionManager(keychainService: keychainService)
                }
                
                it("sends none in user signal") { waitUntil { done in
                    sessionManager.userSignal.observeValues {
                        switch $0 {
                        case .none: done()
                        case .some: fail()
                        }
                    }
                    
                    sessionManager.bootstrap()
                }}
                
            }
            
        }
        
        describe("#login") {
            
            describe("when there is a current session") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    keychainService.set(value: UserMock().sessionToken!,
                                        forKey: SessionManagerSpec.CurrentSessionTokenPersistanceKey)
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.bootstrap()
                }
                
                it("throws an assertion") {
                    expect(sessionManager.login(user: UserMock())).to(throwAssertion())
                }
                
            }
            
            describe("when there is no current session") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.bootstrap()
                }
                
                it("sends true in session signal") { waitUntil { done in
                    sessionManager.sessionSignal.observeValues {
                        switch $0 {
                        case true: done()
                        case false: fail()
                        }
                    }
                    
                    sessionManager.login(user: UserMock())
                }}
                
                it("sends the authenticated user in user signal") { waitUntil { done in
                    sessionManager.userSignal.observeValues {
                        switch $0 {
                        case .none: fail()
                        case .some(let user):
                            expect(user.sessionToken).to(equal(UserMock().sessionToken))
                            done()
                        }
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
                    keychainService = KeychainServiceMock()
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.bootstrap()
                }
                
                it("throws an assertion") {
                    expect(sessionManager.update(user: UserMock())).to(throwAssertion())
                }
                
            }
            
            describe("when there is a current session") {
                
                let updatedSessionToken = "updated-fake-session-token"
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    keychainService.set(value: UserMock().sessionToken!,
                                        forKey: SessionManagerSpec.CurrentSessionTokenPersistanceKey)
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.bootstrap()
                }
                
                it("sends no session signal") {
                    sessionManager.sessionSignal.observeValues { _ in
                        fail()
                    }
                    
                    sessionManager.update(user: UserMock())
                }
                
                it("sends the updated authenticated user in user signal") { waitUntil { done in
                    sessionManager.userSignal.observeValues {
                        switch $0 {
                        case .none: fail()
                        case .some(let user):
                            expect(user.sessionToken).to(equal(updatedSessionToken))
                            done()
                        }
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
                
                it("does not update the session token") {
                    var updatedUser = UserMock()
                    updatedUser.sessionToken = updatedSessionToken
                    sessionManager.update(user: updatedUser)
                    expect(sessionManager.sessionToken).to(equal(UserMock().sessionToken))
                }
                
            }
            
        }
        
        describe("#logout") {
            
            describe("when there is no current session") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.bootstrap()
                }
                
                it("throws an assertion") {
                    expect(sessionManager.logout()).to(throwAssertion())
                }
                
            }
            
            describe("when there is a current session") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    keychainService.set(value: UserMock().sessionToken!,
                                        forKey: SessionManagerSpec.CurrentSessionTokenPersistanceKey)
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.bootstrap()
                }
                
                it("sends false in session signal") { waitUntil { done in
                    sessionManager.sessionSignal.observeValues {
                        switch $0 {
                        case true: fail()
                        case false: done()
                        }
                    }
                    
                    sessionManager.logout()
                }}
                
                it("sends none in user signal") { waitUntil { done in
                    sessionManager.userSignal.observeValues {
                        switch $0 {
                        case .none: done()
                        case .some: fail()
                        }
                    }
                    
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
                    keychainService = KeychainServiceMock()
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.bootstrap()
                }
                
                it("throws an assertion") {
                    expect(sessionManager.expire()).to(throwAssertion())
                }
                
            }
            
            describe("when there is a current session") {
                
                beforeEach {
                    keychainService = KeychainServiceMock()
                    keychainService.set(value: UserMock().sessionToken!,
                                        forKey: SessionManagerSpec.CurrentSessionTokenPersistanceKey)
                    sessionManager = SessionManager(keychainService: keychainService)
                    sessionManager.bootstrap()
                }
                
                it("sends false in session signal") { waitUntil { done in
                    sessionManager.sessionSignal.observeValues {
                        switch $0 {
                        case true: fail()
                        case false: done()
                        }
                    }
                    
                    sessionManager.expire()
                }}
                
                it("sends none in user signal") { waitUntil { done in
                    sessionManager.userSignal.observeValues {
                        switch $0 {
                        case .none: done()
                        case .some: fail()
                        }
                    }
                    
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
