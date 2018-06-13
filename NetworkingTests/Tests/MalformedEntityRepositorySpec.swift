//
//  MalformedEntityRepositorySpec.swift
//  Networking
//
//  Created by Pablo Giorgi on 5/5/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Quick
import Nimble
import Networking

internal class MalformedEntityRepositorySpec: QuickSpec {
    
    override func spec() {
        
        var sessionManager: SessionManagerType!
        var repository: MalformedEntityRepositoryType!
        
        beforeEach() {
            sessionManager = SessionManagerMock()
            sessionManager.login(user: UserMock())
            
            var networkingConfiguration = NetworkingConfiguration()
            
            networkingConfiguration.useSecureConnection = true
            networkingConfiguration.domainURL = "localhost"
            networkingConfiguration.port = 8080
            networkingConfiguration.subdomainURL = "/local-path-1.0"
            networkingConfiguration.usePinningCertificate = false
            
            repository = MalformedEntityRepository(networkingConfiguration: networkingConfiguration,
                                                   requestExecutor: LocalRequestExecutor(),
                                                   sessionManager: sessionManager)
        }
        
        describe("#fetchMalformedEntity") {
            
            it("fetches a single entity from a malformed JSON file") { waitUntil { done in
                repository.fetchMalformedEntity().startWithResult {
                    switch $0 {
                    case .success: fail()
                    case .failure(let error):
                        switch error {
                        case .jsonError: done()
                        default: fail()
                        }
                    }
                }
            }}
            
        }
        
        describe("#fetchMalformedEntityStatusCode") {
            
            it("fetches the response status code from a malformed JSON file") { waitUntil { done in
                repository.fetchMalformedEntityStatusCode().startWithResult {
                    switch $0 {
                    case .success(let statusCode):
                        expect(statusCode).to(equal(200))
                        done()
                    case .failure: fail()
                    }
                }
            }}
            
        }
        
    }
    
}
