//
//  DemoRepository.swift
//  Networking
//
//  Created by Pablo Giorgi on 3/6/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Networking
import Argo
import Result
import ReactiveSwift

internal class DemoRepository: AbstractRepository {

    private static let EntitiesPath = "books"
    private static let PageKey = "page"
    
    private static let ReadPrefixPath = "users"
    private static let ReadSuffixPath = "notifications/read_all"
    
    private static let FirstPage = 1
    
    public func fetchEntities() -> SignalProducer<[Entity], RepositoryError> {
        let path = DemoRepository.EntitiesPath
        let parameters = [DemoRepository.PageKey: DemoRepository.FirstPage]
        return performRequest(method: .get, path: path, parameters: parameters) {
            decode($0).toResult()
        }
    }
    
    public func noAnswerEntities(userID: Int) -> SignalProducer<Void, RepositoryError> {
        let path = DemoRepository.ReadPrefixPath / String(userID) / DemoRepository.ReadSuffixPath
        return performRequest(method: .post, path: path) { _ in
            Result(value: ())
        }
    }
    
}
