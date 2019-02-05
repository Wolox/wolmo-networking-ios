//
//  BooksRepository.swift
//  Networking
//
//  Copyright © 2019 Wolox. All rights reserved.
//

import Networking
import Argo
import Result
import ReactiveSwift

internal class BooksRepository: AbstractRepository {

    private static let BooksPath = "books"
    private static let PageKey = "page"
    private static let FirstPage = 1
    
    public func fetchBooksPage() -> SignalProducer<BooksPage, RepositoryError> {
        let path = BooksRepository.BooksPath
        let parameters = [BooksRepository.PageKey: BooksRepository.FirstPage]
        return performRequest(method: .get, path: path, parameters: parameters) {
            decode($0).toResult()
        }
    }
    
    public func addBook(_ book: Book) -> SignalProducer<Void, RepositoryError> {
        let path = BooksRepository.BooksPath
        let parameters = book.asDictionary()
        return performRequest(method: .post, path: path, parameters: parameters) { _ in
            Result(value: ())
        }
    }
    
}
