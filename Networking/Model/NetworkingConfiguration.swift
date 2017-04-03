//
//  NetworkingConfiguration.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/23/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Foundation

fileprivate enum CommunicationProtocol: String {
    
    case http, https
    
}

public struct NetworkingConfiguration {
    
    fileprivate let _useSecureConnection: Bool
    fileprivate let _domainURL: String
    fileprivate let _port: Int?
    fileprivate let _subdomainURL: String?
    
    fileprivate let _usePinningCertificate: Bool
    
    public init(useSecureConnection: Bool = true,
                domainURL: String,
                port: Int? = .none,
                subdomainURL: String? = .none,
                usePinningCertificate: Bool = false) {
        _useSecureConnection = useSecureConnection
        _domainURL = domainURL
        _port = port
        _subdomainURL = subdomainURL
        _usePinningCertificate = usePinningCertificate
    }
    
}

internal extension NetworkingConfiguration {
    
    var baseURL: URL {
        var components = URLComponents()
        components.scheme = communicationProtocol
        components.host = _domainURL
        components.port = _port
        if let subdomainURL = _subdomainURL {
            components.path = subdomainURL
        }
        if let url = components.url {
            return url
        }
        fatalError("Invalid URL parameters in \(String(describing: NetworkingConfiguration.self))")
    }
    
    var usePinningCertificate: Bool {
        return _usePinningCertificate
    }
    
    var domainURL: String {
        return _domainURL
    }
    
}

fileprivate extension NetworkingConfiguration {
    
    var communicationProtocol: String {
        return _useSecureConnection ? CommunicationProtocol.https.rawValue : CommunicationProtocol.http.rawValue
    }
    
}
