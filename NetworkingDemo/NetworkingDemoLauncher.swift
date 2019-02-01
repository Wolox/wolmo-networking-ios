//
//  NetworkingDemoLauncher.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/28/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Foundation
import Networking
import AlamofireNetworkActivityIndicator
import AlamofireNetworkActivityLogger

class NetworkingDemoLauncher {
    // Provide a valid session token for the demo app to work properly.
    static let sessionToken = ""
    
    private let _fakeUser = UserDemo(sessionToken: NetworkingDemoLauncher.sessionToken, id: 1)
    
    func launch() {
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        createRepositoryAndPerformRequests()
    }
    
}

private extension NetworkingDemoLauncher {
    
    func createRepositoryAndPerformRequests() {
        let repository = DemoRepository(configuration: networkingConfiguration, defaultHeaders: ["Authorization": _fakeUser.sessionToken ?? ""])
        
        repository.fetchEntities().startWithResult {
            switch $0 {
            case .success(let entities): print("\(entities)")
            case .failure(let error):  print("\(error)")
            }
        }
        
        repository.noAnswerEntities(userID: _fakeUser.id).startWithResult {
            switch $0 {
            case .success: print("success")
            case .failure(let error):  print("\(error)")
            }
        }
    }
    
}

fileprivate extension NetworkingDemoLauncher {
    
    var networkingConfiguration: NetworkingConfiguration {
        var config = NetworkingConfiguration()
        config.useSecureConnection = true
        config.domainURL = "wbooks-api-stage.herokuapp.com"
        config.subdomainURL = "/api/v1"
        config.usePinningCertificate = false
        return config
    }
    
}
