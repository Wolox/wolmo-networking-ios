//
//  NetworkingSessionManager.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/24/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Alamofire

/**
    Class that wraps Alamofire.SessionManager.
    In case the networking configuration for the project enables SSL Pinning
    this class is in charge of creating the proper server policy manager.
 */
internal final class NetworkingSessionManager: Alamofire.SessionManager {
    
    internal init(networkingConfiguration: NetworkingConfiguration) {
        var trustPolicyManager: ServerTrustPolicyManager?
        if networkingConfiguration.usePinningCertificate {
            trustPolicyManager = serverTrustPolicyManager(domainURL: networkingConfiguration.domainURL)
        }
        super.init(configuration: defaultSessionConfiguration(networkingConfiguration), serverTrustPolicyManager: trustPolicyManager)
    }
    
}

/**
    Default session configuration which does not accept cookies by default and sets
    the timeouts to the values set in the networkingConfiguration provided.
 */
private func defaultSessionConfiguration(_ networkingConfiguration: NetworkingConfiguration) -> URLSessionConfiguration {
    let configuration = URLSessionConfiguration.default
    configuration.httpCookieStorage?.cookieAcceptPolicy = .never
    configuration.timeoutIntervalForRequest = networkingConfiguration.timeout
    configuration.timeoutIntervalForResource = networkingConfiguration.timeout
    return configuration
}

/**
    Server policy manager used in case SSL Pinning is enabled.
    This function looks for a proper certificate in Bundle, and links it with
    the base URL provided in networking configuration. It also validates 
    certificate chain and the host.
 */
private func serverTrustPolicyManager(domainURL: String) -> ServerTrustPolicyManager {
    let serverTrustPolicies: [String: ServerTrustPolicy] = [
        domainURL: .pinCertificates(
            certificates: ServerTrustPolicy.certificates(),
            validateCertificateChain: true,
            validateHost: true
        )
    ]
    return ServerTrustPolicyManager(policies: serverTrustPolicies)
}
