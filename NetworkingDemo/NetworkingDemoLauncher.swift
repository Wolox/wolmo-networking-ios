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

class NetworkingDemoLauncher {
    
    fileprivate let _sessionManager = SessionManager()
    
    func launch() {
        enableAlamofireLogger()
        enableNetworkActivityIndicatorManager()
        authenticateFakeUser()
        injectCurrentUserFetcher()
        bootstrapSessionManager()
        createRepositoryAndPerformRequests()
    }
    
}

private extension NetworkingDemoLauncher {
    
    func enableAlamofireLogger() {
        AlamofireLogger.sharedInstance.logEnabled = true
    }
    
    func enableNetworkActivityIndicatorManager() {
        NetworkActivityIndicatorManager.shared.isEnabled = true
    }
    
    func authenticateFakeUser() {
        let fakeUser = UserDemo(sessionToken: NetworkingDemoLauncher.sessionToken, id: 1)
        _sessionManager.login(user: fakeUser)
    }
    
    func injectCurrentUserFetcher() {
        let currentUserFetcher = CurrentUserFetcher(
            networkingConfiguration: networkingConfiguration,
            sessionManager: _sessionManager)
        
        _sessionManager.setCurrentUserFetcher(currentUserFetcher: currentUserFetcher)
    }
    
    func bootstrapSessionManager() {
        _sessionManager.bootstrap()
    }
    
    func createRepositoryAndPerformRequests() {
        let repository = DemoRepository(
            networkingConfiguration: networkingConfiguration,
            sessionManager: _sessionManager)
        
        repository.fetchEntities().startWithResult {
            switch $0 {
            case .success(let entities): print("\(entities)")
            case .failure(let error):  print("\(error)")
            }
        }
        
        let user = _sessionManager.currentUser as! UserDemo
        repository.noAnswerEntities(userID: user.id).startWithResult {
            switch $0 {
            case .success(): print("success")
            case .failure(let error):  print("\(error)")
            }
        }
    }
    
}

fileprivate extension NetworkingDemoLauncher {

    static let sessionToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxOCwidmVyaWZpY2F0aW9uX2NvZGUiOiJLVVI4NTR4V1pLODFMY25ael8yek5RVmV6RmJoUWUyc0Jkc3VCSlRKenYxS2ZkMUZ5YXFTN1lwWGtfeE44dVlRIiwicmVuZXdfaWQiOiJKazNLWFIzX3lIOXh4TVN1RXMtUVJETUh4V00xbnZHaGFVOGVQVzJzMjZabXk1alBSdld6R1NueWdzc0hVRXBXIiwibWF4aW11bV91c2VmdWxfZGF0ZSI6MTQ5MzMyNjQ0MCwiZXhwaXJhdGlvbl9kYXRlIjoxNDkwOTA3MjQwLCJ3YXJuaW5nX2V4cGlyYXRpb25fZGF0ZSI6MTQ5MDc1MjQ0MH0.JS08dl5iN0dUDG3HVTvEt2VUaVvOsnNdb_Ue6V-Pw7E"
    
    var networkingConfiguration: NetworkingConfiguration {
        return NetworkingConfiguration(
            useSecureConnection: true,
            domainURL: "wbooks-api-stage.herokuapp.com",
            subdomainURL: "api",
            versionAPI: "v1",
            usePinningCertificate: false)
    }
    
}
