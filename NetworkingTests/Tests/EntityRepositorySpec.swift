//
//  EntityRepositorySpec.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/24/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Quick
import Nimble
import Networking

internal class EntityRepositorySpec: QuickSpec {
    
    override func spec() {
        
        var sessionManager: SessionManagerType!
        var repository: EntityRepositoryType!
        
        beforeEach() {
            sessionManager = SessionManagerMock()
            sessionManager.login(user: UserMock())
            
            var networkingConfiguration = NetworkingConfiguration()
            
            networkingConfiguration.useSecureConnection = true
            networkingConfiguration.domainURL = "localhost"
            networkingConfiguration.port = 8080
            networkingConfiguration.subdomainURL = "/local-path-1.0"
            networkingConfiguration.usePinningCertificate = false
            
            repository = EntityRepository(networkingConfiguration: networkingConfiguration,
                                          requestExecutor: LocalRequestExecutor(),
                                          sessionManager: sessionManager)
        }
        
        describe("#fetchEntity") {
            
            context("when session is valid") {
                
                it("fetches a single entity from JSON file") { waitUntil { done in
                    repository.fetchEntity().startWithResult {
                        switch $0 {
                        case .success: done()
                        case .failure: fail()
                        }
                    }
                }}
                
            }
            
            context("when session is not valid", {
                
                beforeEach {
                    sessionManager.expire()
                }
                
                it("fetches a single entity from JSON file") { waitUntil { done in
                    repository.fetchEntity().startWithResult {
                        switch $0 {
                        case .success: fail()
                        case .failure(let error):
                            switch error {
                            case .unauthenticatedSession: done()
                            default: fail()
                            }
                        }
                    }
                }}
                
            })
            
        }
        
        describe("#fetchEnumEntity") {
            
            it("fetches a single entity that has several enum fields of several types from a JSON file") { waitUntil { done in
                repository.fetchEnumEntity().startWithResult {
                    switch $0 {
                    case .success: done()
                    case .failure: fail()
                    }
                }
            }}
            
        }
        
        describe("#fetchFailingEnumEntity") {
            
            afterEach {
                DecodedErrorHandler.decodedErrorHandler = { _ in }
            }
            
            it("fetches a single entity that has an incorrect enum type from a JSON file and fails with custom error") { waitUntil { done in
                DecodedErrorHandler.decodedErrorHandler = {
                    switch $0 {
                    case let .custom(string): expect(string == "Invalid EnumDoubleEntityState enum value").to(beTrue())
                    default: fail()
                    }
                    done()
                }
                
                repository.fetchFailingEnumEntity().startWithResult {
                    switch $0 {
                    case .success: fail()
                    case .failure: break // done() to be executed in DecodedErrorHandler.decodedErrorHandler
                    }
                }
            }}
            
        }
        
        describe("#fetchEntityTryingPolling") {
            
            it("fetches a single entity from JSON using polling") { waitUntil { done in
                repository.fetchEntityTryingPolling().startWithResult {
                    switch $0 {
                    case .success: done()
                    case .failure: fail()
                    }
                }
            }}
            
        }

        describe("#fetchEntities") {
         
            it("fetches an entity collection from JSON file") { waitUntil { done in
                repository.fetchEntities().startWithResult {
                    switch $0 {
                    case .success: done()
                    case .failure: fail()
                    }
                }
            }}
            
        }
         
        describe("#fetchFailingEntity") {
            
            it("fetches a single entity from JSON file and fails") { waitUntil { done in
                repository.fetchFailingEntity().startWithResult {
                    switch $0 {
                    case .success: fail()
                    case .failure: done()
                    }
                }
            }}
            
        }
        
        describe("#fetchFailingEntity") {
            
            context("when there is an error handler") {
                
                afterEach {
                    DecodedErrorHandler.decodedErrorHandler = { _ in }
                }
                
                it("fetches a single entity from JSON file and fails executing error handler") { waitUntil { done in
                    DecodedErrorHandler.decodedErrorHandler = {
                        expect($0).notTo(beNil())
                        done()
                    }
                    
                    repository.fetchFailingEntity().startWithResult {
                        switch $0 {
                        case .success: fail()
                        case .failure: break // done() to be executed in DecodedErrorHandler.decodedErrorHandler
                        }
                    }
                }}
                
            }
            
            context("when there is no error handler") {
                
                it("fetches a single entity from JSON file and fails") { waitUntil { done in
                    repository.fetchFailingEntity().startWithResult {
                        switch $0 {
                        case .success: fail()
                        case .failure: done()
                        }
                    }
                }}
                
            }
            
        }
 
        describe("#fetchDefaultFailingEntity") {
            
            it("fetches a single entity from JSON file and fails with a default error") { waitUntil { done in
                repository.fetchDefaultFailingEntity().startWithResult {
                    switch $0 {
                    case .success: fail()
                    case .failure(let error):
                        switch error {
                        case .requestError(let requestError):
                            let expectedErrorCode = 400
                            expect(requestError.error.code == expectedErrorCode).to(beTrue())
                            done()
                        default: fail()
                        }
                    }
                }
            }}
            
        }
        
        describe("#fetchCustomFailingEntity") {
            
            it("fetches a single entity from JSON file and fails with a custom error") { waitUntil { done in
                repository.fetchCustomFailingEntity().startWithResult {
                    switch $0 {
                    case .success: fail()
                    case .failure(let error):
                        switch error {
                        case .customError(let customError):
                            // What is the correct way to make this enum comparison?
                            // I'd like to use a switch here, how should I declare CustomRepositoryErrorType?
                            let expectedError: CustomRepositoryErrorType = EntityRepositoryError.madeUpError
                            expect(customError.errorName == expectedError.name).to(beTrue())
                            done()
                        default: fail()
                        }
                    }
                }
            }}
            
        }
        
        describe("#fetchCustomFailingEntityMishandlingError") {
            
            it("fetches a single entity from JSON file and fails with a custom error mishandled") { waitUntil { done in
                repository.fetchCustomFailingEntityMishandlingError().startWithResult {
                    switch $0 {
                    case .success: fail()
                    case .failure(let error):
                        switch error {
                        case .requestError: done()
                        default: fail()
                        }
                    }
                }
            }}
            
        }
        
    }
    
}
