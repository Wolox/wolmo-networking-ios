//
//  MalformedEntityRepository.swift
//  Networking
//
//  Created by Pablo Giorgi on 5/5/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift
import Networking
import Argo
import Result

internal protocol MalformedEntityRepositoryType {
    
    func fetchMalformedEntity() -> SignalProducer<Entity, RepositoryError>
    func fetchMalformedEntityStatusCode() -> SignalProducer<Int, RepositoryError>
    
}

internal class MalformedEntityRepository: AbstractRepository, MalformedEntityRepositoryType {
    
    internal init(networkingConfiguration: NetworkingConfiguration,
                  requestExecutor: RequestExecutorType,
                  sessionManager: SessionManagerType) {
        super.init(networkingConfiguration: networkingConfiguration,
                   requestExecutor: requestExecutor,
                   sessionManager: sessionManager,
                   defaultHeaders: ["Content-Type": "application/json", "Accept": "application/json"])
    }
    
    func fetchMalformedEntity() -> SignalProducer<Entity, RepositoryError> {
        return performRequest(method: .get, path: "malformed-entity") {
            decode($0).toResult()
        }
    }
    
    func fetchMalformedEntityStatusCode() -> SignalProducer<Int, RepositoryError> {
        return performRequest(method: .get, path: "malformed-entity")
            .flatMap(.concat) { (_, response, _) -> SignalProducer<Int, RepositoryError> in
                return SignalProducer(value: response.statusCode)
            }
    }
    
}
