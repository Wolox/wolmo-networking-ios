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
    private let _fakeUser = UserDemo(sessionToken: "fakeToken", id: 1)
    
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
        
        repository.fetchEntityPage().startWithResult {
            switch $0 {
            case .success(let entityPage): print("\(entityPage.data)")
            case .failure(let error):  print("\(error)")
            }
        }
        
        repository.noAnswerEntities().startWithResult {
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
        config.domainURL = "swift-training-backend.herokuapp.com"
        return config
    }
    
}
