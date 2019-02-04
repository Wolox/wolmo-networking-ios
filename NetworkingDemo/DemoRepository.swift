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
    private static let FirstPage = 1
    
    public func fetchEntityPage() -> SignalProducer<EntityPage, RepositoryError> {
        let path = DemoRepository.EntitiesPath
        let parameters = [DemoRepository.PageKey: DemoRepository.FirstPage]
        return performRequest(method: .get, path: path, parameters: parameters) {
            decode($0).toResult()
        }
    }
    
    public func noAnswerEntities() -> SignalProducer<Void, RepositoryError> {
        let path = DemoRepository.EntitiesPath
        let parameters = [ "author": "J.R.R Wolox",
                           "title": "Books Training",
                           "image": "some_url",
                           "year": "2019",
                           "genre": "Technology"]
        return performRequest(method: .post, path: path, parameters: parameters) { _ in
            Result(value: ())
        }
    }
    
}
