//
//  NetworkingSessionManager.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/24/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Alamofire

internal final class NetworkingSessionManager: Alamofire.SessionManager {
    
    internal init(networkingConfiguration: NetworkingConfiguration) {
        var trustPolicyManager: ServerTrustPolicyManager?
        if networkingConfiguration.usePinningCertificate {
            trustPolicyManager = serverTrustPolicyManager(domainURL: networkingConfiguration.domainURL)
        }
        super.init(configuration: defaultSessionConfiguration, serverTrustPolicyManager: trustPolicyManager)
    }
    
}

private var defaultSessionConfiguration: URLSessionConfiguration {
    let configuration = URLSessionConfiguration.default
    configuration.httpCookieStorage?.cookieAcceptPolicy = .never
    return configuration
}

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
