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
    
    fileprivate let _userManager = UserManager()
    
    func launch() {
        enableAlamofireNetworkActivityLogger()
        enableNetworkActivityIndicatorManager()
        authenticateFakeUser()
        injectCurrentUserFetcher()
        bootstrapSessionManager()
        createRepositoryAndPerformRequests()
    }
    
}

private extension NetworkingDemoLauncher {
    
    func enableAlamofireNetworkActivityLogger() {
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .debug
    }
    
    func enableNetworkActivityIndicatorManager() {
        NetworkActivityIndicatorManager.shared.isEnabled = true
    }
    
    func authenticateFakeUser() {
        let fakeUser = UserDemo(sessionToken: NetworkingDemoLauncher.sessionToken, id: 1)
        _userManager.login(user: fakeUser)
    }
    
    func injectCurrentUserFetcher() {
        let currentUserFetcher = CurrentUserFetcher(configuration: networkingConfiguration)
        _userManager.setCurrentUserFetcher(currentUserFetcher: currentUserFetcher)
    }
    
    func bootstrapSessionManager() {
        _userManager.bootstrap()
    }
    
    func createRepositoryAndPerformRequests() {
        let repository = DemoRepository(configuration: networkingConfiguration, defaultHeaders: ["Authorization": _userManager.sessionToken ?? ""])
        
        repository.fetchEntities().startWithResult {
            switch $0 {
            case .success(let entities): print("\(entities)")
            case .failure(let error):  print("\(error)")
            }
        }
        
        let user = _userManager.currentUser as! UserDemo //swiftlint:disable:this force_cast
        repository.noAnswerEntities(userID: user.id).startWithResult {
            switch $0 {
            case .success: print("success")
            case .failure(let error):  print("\(error)")
            }
        }
    }
    
}

fileprivate extension NetworkingDemoLauncher {

    // Provide a valid session token for the demo app to work properly.
    static let sessionToken = ""
    
    var networkingConfiguration: NetworkingConfiguration {
        var config = NetworkingConfiguration()
        config.useSecureConnection = true
        config.domainURL = "wbooks-api-stage.herokuapp.com"
        config.subdomainURL = "/api/v1"
        config.usePinningCertificate = false
        return config
    }
    
}
