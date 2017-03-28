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
    fileprivate let _subdomainURL: String
    fileprivate let _versionAPI: String
    
    fileprivate let _usePinningCertificate: Bool
    
    public init(useSecureConnection: Bool = true,
                domainURL: String,
                subdomainURL: String = "",
                versionAPI: String = "",
                usePinningCertificate: Bool = false) {
        _useSecureConnection = useSecureConnection
        _domainURL = domainURL
        _subdomainURL = subdomainURL
        _versionAPI = versionAPI
        _usePinningCertificate = usePinningCertificate
    }
    
}

internal extension NetworkingConfiguration {
    
    var baseURL: String {
        return communicationProtocol + "://" + _domainURL + subdomain + version
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
    
    var subdomain: String {
        return _subdomainURL.characters.count > 0 ? "/" + _subdomainURL : ""
    }
    
    var version: String {
        return _versionAPI.characters.count > 0 ? "/" + _versionAPI : ""
    }
    
}
