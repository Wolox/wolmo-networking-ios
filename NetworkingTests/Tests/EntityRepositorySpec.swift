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

class EntityRepositorySpec: QuickSpec {
    
    override func spec() {
        
        var sessionManager: SessionManagerType!
        var repository: EntityRepositoryType!
        
        beforeEach() {
            let user = UserMock()
            sessionManager = SessionManagerMock()
            sessionManager.login(user: user)
            
            let networkingConfiguration = NetworkingConfiguration(useSecureConnection: true,
                                                                  domainURL: "localhost",
                                                                  port: 8080,
                                                                  subdomainURL: "/local-path-1.0",
                                                                  usePinningCertificate: false)
            
            repository = EntityRepository(networkingConfiguration:networkingConfiguration,
                                          requestExecutor: LocalRequestExecutor(),
                                          sessionManager: sessionManager)
        }
        
        describe("#fetchEntity") {
            
            it("fetches a single entity from JSON file") { waitUntil { done in
                repository.fetchEntity().startWithResult {
                    switch $0 {
                    case .success: done()
                    case .failure: return
                    }
                }
            }}
            
        }

        describe("#fetchEntities") {
         
            it("fetches an entity collection from JSON file") { waitUntil { done in
                repository.fetchEntities().startWithResult {
                    switch $0 {
                    case .success: done()
                    case .failure: return
                    }
                }
            }}
            
        }
         
        describe("#fetchFailingEntity") {
            
            it("fetches a single entity from JSON file and fails") { waitUntil { done in
                repository.fetchFailingEntity().startWithResult {
                    switch $0 {
                    case .success: return
                    case .failure: done()
                    }
                }
            }}
            
        }
        
        describe("#fetchFailingEntity") {
            
            context("when there is an error handler") {
                
                beforeEach {
                    DecodedErrorHandler.decodedErrorHandler = {
                        // TODO: Ensure this code is executed...
                        expect($0).notTo(beNil())
                    }
                }
                
                it("fetches a single entity from JSON file and fails executing error handler") { waitUntil { done in
                    repository.fetchFailingEntity().startWithResult {
                        switch $0 {
                        case .success: return
                        case .failure: done()
                        }
                    }
                }}
                
            }
            
            context("when there is no error handler") {
                
                it("fetches a single entity from JSON file and fails") { waitUntil { done in
                    repository.fetchFailingEntity().startWithResult {
                        switch $0 {
                        case .success: return
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
                    case .success: return
                    case .failure(let error):
                        switch error {
                        case .requestError(let requestError):
                            let expectedErrorCode = 400
                            expect(requestError.error.code == expectedErrorCode).to(beTrue())
                            done()
                        default: return
                        }
                    }
                }
            }}
            
        }
        
        describe("#fetchCustomFailingEntity") {
            
            it("fetches a single entity from JSON file and fails with a custom error") { waitUntil { done in
                repository.fetchCustomFailingEntity().startWithResult {
                    switch $0 {
                    case .success: return
                    case .failure(let error):
                        switch error {
                        case .customError(let customError):
                            // What is the correct way to make this enum comparison?
                            // I'd like to use a switch here, how should I declare CustomRepositoryErrorType?
                            let expectedError: CustomRepositoryErrorType = EntityRepositoryError.madeUpError
                            expect(customError.localizedDescription == expectedError.localizedDescription).to(beTrue())
                            done()
                        default: return
                        }
                    }
                }
            }}
            
        }
        
    }
    
}
