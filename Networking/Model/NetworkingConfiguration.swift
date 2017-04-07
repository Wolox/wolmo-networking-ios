//
//  NetworkingConfiguration.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/23/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Foundation

/**
    Represents a connection scheme
 */
fileprivate enum CommunicationProtocol: String {
    
    case http, https
    
}

/**
    Stores the parameters used to initialize the networking configuration
    for the application.
    It's the only place where these necessary parameters are configured.
 */
public struct NetworkingConfiguration {
    
    fileprivate let _useSecureConnection: Bool
    fileprivate let _domainURL: String
    fileprivate let _port: Int?
    fileprivate let _subdomainURL: String?
    
    fileprivate let _usePinningCertificate: Bool
    
    /**
        Initializes the networking configuration.
     
        - Parameters
            - useSecureConnection: a boolean representing whether the requests
            will be made using a secure protocol. By default it's enabled.
            Take into account in case this is disabled, the appropriate
            exclusions must be added to plist file.
            - domainURL: the base url the requests will be performed against.
            - port: the port the requests will be performed against. By default 
            there is no specific port.
            - subdomainURL: the subdomain url to be appended to domainURL to build
            the final url (it can be used to specify API versioning). By default it's empty. 
            This url, as a path of the domainURL must start with "/".
            - usePinningCertificate: a boolean representing if SSL Pinning will be 
            enabled for the performed requests. By default it's disabled. Take into 
            account in case this is enabled, the proper certificate must be included
            into the application bundle resources.
    */
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
