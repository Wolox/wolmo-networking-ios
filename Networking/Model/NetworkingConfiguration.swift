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
private enum CommunicationProtocol: String {
    
    case http, https
    
}

/**
    Stores the parameters used to initialize the networking configuration
    for the application.
    It's the only place where these necessary parameters are configured.
 */
public struct NetworkingConfiguration {
    /// A boolean representing whether the requests will be made using a secure protocol. By default it's enabled.
    /// Take into account in case this is disabled, the appropriate exclusions must be added to plist file.
    public var useSecureConnection: Bool = true
    
    /// The base url the requests will be performed against.
    public var domainURL: String = ""
    
    /// The port the requests will be performed against. By default there is no specific port.
    public var port: Int? = .none
    
    /// The subdomain url to be appended to domainURL to build the final url (it can be used to specify API versioning). By default it's empty.
    /// This url, as a path of the domainURL must start with "/".
    public var subdomainURL: String? = .none
    
    /// A boolean representing if SSL Pinning will be enabled for the performed requests. By default it's disabled.
    /// Take into account in case this is enabled, the proper certificate must be included into the application bundle resources.
    public var usePinningCertificate: Bool = false
    
    /// The timeout of the requests in seconds. It defaults to 75 seconds.
    public var timeout: Double = 75.0
    
    /// For polling requests, seconds between one polling and the next. It defaults to 1 second.
    public var secondsBetweenPolls: Double = 1.0
    
    /// Maximum retries until a polling request gives timeout. If it's not set then it will use timeout/secondsBetweenPolls
    public var maximumPollingRetries: Int? = .none
    
    /**
         Initializes the networking configuration with default values.
     */
    public init() {}

}

internal extension NetworkingConfiguration {
    
    var baseURL: URL {
        var components = URLComponents()
        components.scheme = communicationProtocol
        components.host = domainURL
        components.port = port
        if let subdomainURL = subdomainURL {
            components.path = subdomainURL
        }
        if let url = components.url {
            return url
        }
        fatalError("Invalid URL parameters in \(String(describing: NetworkingConfiguration.self))")
    }
    
    /**
         Returns a default number of times that a polling request will try. In seconds it will match the timeout property.
     */
    var defaultPollingRetries: Int {
        return lround(timeout/secondsBetweenPolls)
    }
    
}

fileprivate extension NetworkingConfiguration {
    
    var communicationProtocol: String {
        return useSecureConnection ? CommunicationProtocol.https.rawValue : CommunicationProtocol.http.rawValue
    }
    
}
