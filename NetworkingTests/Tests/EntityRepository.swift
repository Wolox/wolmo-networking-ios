//
//  EntityRepository.swift
//  Networking
//
//  Created by Pablo Giorgi on 1/24/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift
import Networking
import Argo
import Result

internal enum EntityRepositoryError: String, CustomRepositoryErrorType {
    case madeUpError
}

internal protocol EntityRepositoryType {
    
    func fetchEntity() -> SignalProducer<Entity, RepositoryError>
    func fetchEntities() -> SignalProducer<[Entity], RepositoryError>
    func fetchFailingEntity() -> SignalProducer<Entity, RepositoryError>
    func fetchDefaultFailingEntity() -> SignalProducer<Entity, RepositoryError>
    func fetchCustomFailingEntity() -> SignalProducer<Entity, RepositoryError>
    
}

internal class EntityRepository: AbstractRepository, EntityRepositoryType {
    
    private static let PageKey = "page"
    
    func fetchEntity() -> SignalProducer<Entity, RepositoryError> {
        return performRequest(method: .get, path: "entity", parameters: .none) {
            decode($0).toResult()
        }
    }
    
    func fetchEntities() -> SignalProducer<[Entity], RepositoryError> {
        return performRequest(method: .get, path: "entities", parameters: .none) {
            if let page = $0[EntityRepository.PageKey] {
                return decode(page!).toResult()
            }
            return Result(error: Argo.DecodeError.missingKey(EntityRepository.PageKey))
        }
    }
    
    func fetchFailingEntity() -> SignalProducer<Entity, RepositoryError> {
        return performRequest(method: .get, path: "failing-entity", parameters: .none) {
            decode($0).toResult()
        }
    }
    
    func fetchDefaultFailingEntity() -> SignalProducer<Entity, RepositoryError> {
        return performRequest(method: .get, path: "not-found", parameters: .none) {
            decode($0).toResult()
        }
    }
    
    func fetchCustomFailingEntity() -> SignalProducer<Entity, RepositoryError> {
        return performRequest(method: .get, path: "not-found", parameters: .none) {
            decode($0).toResult()
        }.mapCustomError(errors: [400: EntityRepositoryError.madeUpError])
    }
    
}
