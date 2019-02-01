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
    func fetchEnumEntity() -> SignalProducer<EnumEntity, RepositoryError>
    func fetchFailingEnumEntity() -> SignalProducer<EnumEntity, RepositoryError>
    func fetchEntityTryingPolling() -> SignalProducer<Entity, RepositoryError>
    func fetchEntities() -> SignalProducer<[Entity], RepositoryError>
    func fetchFailingEntity() -> SignalProducer<Entity, RepositoryError>
    func fetchDefaultFailingEntity() -> SignalProducer<Entity, RepositoryError>
    func fetchCustomFailingEntity() -> SignalProducer<Entity, RepositoryError>
    func fetchCustomFailingEntityMishandlingError() -> SignalProducer<Entity, RepositoryError>
    func fetchEntityWithArrayParameters() -> SignalProducer<Entity, RepositoryError>
    
}

internal class EntityRepository: AbstractRepository, EntityRepositoryType {
    
    private static let PageKey = "page"
    
    func fetchEntity() -> SignalProducer<Entity, RepositoryError> {
        return performRequest(method: .get, path: "entity") {
            decode($0).toResult()
        }
    }
    
    func fetchEnumEntity() -> SignalProducer<EnumEntity, RepositoryError> {
        return performRequest(method: .get, path: "enum-entity") {
            decode($0).toResult()
        }
    }
    
    func fetchFailingEnumEntity() -> SignalProducer<EnumEntity, RepositoryError> {
        return performRequest(method: .get, path: "failing-enum-entity") {
            decode($0).toResult()
        }
    }
    
    func fetchEntityTryingPolling() -> SignalProducer<Entity, RepositoryError> {
        return performPollingRequest(method: .get, path: "entity") {
            decode($0).toResult()
        }
    }
    
    func fetchEntities() -> SignalProducer<[Entity], RepositoryError> {
        return performRequest(method: .get, path: "entities") {
            if let pageField = $0[EntityRepository.PageKey], let page = pageField {
                return decode(page).toResult()
            }
            return Result(error: Argo.DecodeError.missingKey(EntityRepository.PageKey))
        }
    }
    
    func fetchFailingEntity() -> SignalProducer<Entity, RepositoryError> {
        return performRequest(method: .get, path: "failing-entity") {
            decode($0).toResult()
        }
    }
    
    func fetchDefaultFailingEntity() -> SignalProducer<Entity, RepositoryError> {
        return performRequest(method: .get, path: "not-found") {
            decode($0).toResult()
        }
    }
    
    func fetchCustomFailingEntity() -> SignalProducer<Entity, RepositoryError> {
        return performRequest(method: .get, path: "not-found") {
            decode($0).toResult()
        }.mapCustomError(errors: [400: EntityRepositoryError.madeUpError])
    }
    
    func fetchCustomFailingEntityMishandlingError() -> SignalProducer<Entity, RepositoryError> {
        return performRequest(method: .get, path: "not-found") {
            decode($0).toResult()
        }.mapCustomError(errors: [399: EntityRepositoryError.madeUpError])
    }
    
    func fetchEntityWithArrayParameters() -> SignalProducer<Entity, RepositoryError> {
        let parameters: [Any] = ["someParam", 1, "other", 25]
        return performRequest(method: .get, path: "entity", parameters: parameters) {
            decode($0).toResult()
        }
    }
    
}
