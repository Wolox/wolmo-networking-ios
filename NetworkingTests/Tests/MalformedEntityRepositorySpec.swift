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
            
            let networkingConfiguration = NetworkingConfiguration(useSecureConnection: true,
                                                                  domainURL: "localhost",
                                                                  port: 8080,
                                                                  subdomainURL: "/local-path-1.0",
                                                                  usePinningCertificate: false)
            
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
            
            it("fetches a header from a malformed JSON file") { waitUntil { done in
                repository.fetchMalformedEntityStatusCode().startWithResult {
                    switch $0 {
                    case .success: done()
                    case .failure: fail()
                    }
                }
            }}
            
        }
        
    }
    
}
