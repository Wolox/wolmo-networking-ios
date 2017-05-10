//
//  NetworkingConfigurationSpec.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/29/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Quick
import Nimble
@testable import Networking

internal class NetworkingConfigurationSpec: QuickSpec {
    
    override func spec() {
        
        var configuration: NetworkingConfiguration!
        
        describe("#baseURL") {
            
            context("when using http protocol") {
                
                beforeEach {
                    configuration = NetworkingConfiguration(useSecureConnection: false, domainURL: "www.wolox.com.ar")
                }
                
                it("returns a base url using http protocol") {
                    expect(configuration.baseURL.absoluteString.hasPrefix("https")).to(beFalse())
                    expect(configuration.baseURL.absoluteString.hasPrefix("http")).to(beTrue())
                }
                
            }
            
            context("when using https protocol") {
                
                beforeEach {
                    configuration = NetworkingConfiguration(useSecureConnection: true, domainURL: "www.wolox.com.ar")
                }
                
                it("returns a base url using https protocol") {
                    expect(configuration.baseURL.absoluteString.hasPrefix("https")).to(beTrue())
                }
                
            }
            
        }
        
        describe("#baseURL") {
            
            context("when there is port and subdomain") {
                
                beforeEach {
                    configuration = NetworkingConfiguration(
                        domainURL: "www.wolox.com.ar",
                        port: 8080,
                        subdomainURL: "/api/v1")
                }
                
                it("returns a base url with port and subdomain") {
                    expect(configuration.baseURL.absoluteString).to(equal("https://www.wolox.com.ar:8080/api/v1"))
                }
                
            }
            
            context("when there is port") {
                
                beforeEach {
                    configuration = NetworkingConfiguration(domainURL: "www.wolox.com.ar", port: 8080)
                }
                
                it("returns a base url with port") {
                    expect(configuration.baseURL.absoluteString).to(equal("https://www.wolox.com.ar:8080"))
                }
                
            }
            
            context("when there is subdomain") {
                
                beforeEach {
                    configuration = NetworkingConfiguration(domainURL: "www.wolox.com.ar", subdomainURL: "/api")
                }
                
                it("returns a base url with subdomain") {
                    expect(configuration.baseURL.absoluteString).to(equal("https://www.wolox.com.ar/api"))
                }
                
            }
            
        }
        
    }
    
}
