//
//  Book.swift
//  Networking
//
//  Copyright © 2019 Wolox. All rights reserved.
//

import Argo
import Curry
import Runes

public struct Book {
    let title: String
    let author: String
    let genre: String
    let image: String
    let year: String
}

extension Book: Argo.Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<Book> {
        return curry(Book.init)
            <^> json <| "title"
            <*> json <| "author"
            <*> json <| "genre"
            <*> json <| "image"
            <*> json <| "year"
    }
    
}

extension Book {
    public func asDictionary() -> [String: Any] {
        return
            [ "author": author,
              "title": title,
              "image": image,
              "year": year,
              "genre": genre
            ]
    }
    
}
