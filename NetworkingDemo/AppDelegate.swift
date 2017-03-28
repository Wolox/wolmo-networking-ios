//
//  AppDelegate.swift
//  NetworkingDemo
//
//  Created by Pablo Giorgi on 3/3/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import UIKit
import Networking
import AlamofireNetworkActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        launch()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

private extension AppDelegate {
    
    func launch() {
        
        // Enable alamofire logger.
        
        AlamofireLogger.sharedInstance.logEnabled = true
        
        // Enable network activity indicator.
        
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        // Create networking configuration with API parameters.
        
        let networkingConfiguration = NetworkingConfiguration(
            useSecureConnection: true,
            domainURL: "wbooks-api-stage.herokuapp.com",
            subdomainURL: "api",
            versionAPI: "v1",
            usePinningCertificate: false)
        
        // Create session manager.
        
        let sessionManager = SessionManager()
        
        // Authenticate fake user using a valid session token.
        
        let sessionToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxOCwidmVyaWZpY2F0aW9uX2NvZGUiOiJLVVI4NTR4V1pLODFMY25ael8yek5RVmV6RmJoUWUyc0Jkc3VCSlRKenYxS2ZkMUZ5YXFTN1lwWGtfeE44dVlRIiwicmVuZXdfaWQiOiJXRkRnZk42WFE3eHRtZkZFdURmRUg4V3VBUmV0ZUxqeSIsIm1heGltdW1fdXNlZnVsX2RhdGUiOjE0OTI3OTAzMzcsImV4cGlyYXRpb25fZGF0ZSI6MTQ5MDM3MTEzNywid2FybmluZ19leHBpcmF0aW9uX2RhdGUiOjE0OTAyMTYzMzd9.Wcqkf8gEqhPmvnrq9t0eb-9wjYhvwr87OnCIFQJ9K8A"
        
        let fakeUser = UserDemo(sessionToken: sessionToken, id: 1)
        sessionManager.login(user: fakeUser)
        
        // Create and set current user fetcher, since a user is needed in the app.
        
        let currentUserFetcher = CurrentUserFetcher(
            networkingConfiguration: networkingConfiguration,
            sessionManager: sessionManager)
        
        sessionManager.setCurrentUserFetcher(currentUserFetcher: currentUserFetcher)
        
        // Bootstrap session
        
        sessionManager.bootstrap()
        
        // Create repository and perform requests.
        
        let repository = DemoRepository(
            networkingConfiguration: networkingConfiguration,
            sessionManager: sessionManager)
        
        repository.fetchEntities().startWithResult {
            switch $0 {
            case .success(let notifications): print("\(notifications)")
            case .failure(let error):  print("\(error)")
            }
        }
        
        let user = sessionManager.currentUser as! UserDemo
        repository.noAnswerEntities(userID: user.id).startWithResult {
            switch $0 {
            case .success(): print("success")
            case .failure(let error):  print("\(error)")
            }
        }
        
    }
    
}
